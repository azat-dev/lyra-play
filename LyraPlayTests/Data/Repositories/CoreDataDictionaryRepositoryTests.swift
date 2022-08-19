//
//  CoreDataDictionaryRepositoryTests.swift
//  LyraPlayTests
//
//  Created by Azat Kaiumov on 19.07.22.
//

import XCTest
import LyraPlay
import CoreData


class CoreDataDictionaryRepositoryTests: XCTestCase {
    
    typealias SUT = DictionaryRepository
    
    func createSUT(file: StaticString = #filePath, line: UInt = #line) -> SUT {

        let storeURL = URL(fileURLWithPath: "/dev/null")
        let coreDataStore = try! CoreDataStore(storeURL: storeURL)
        let repository = CoreDataDictionaryRepository(coreDataStore: coreDataStore)
        
        detectMemoryLeak(instance: repository, file: file, line: line)
        return repository
    }
    
    
    func anyTranslationId() -> UUID {
        return .init(uuidString: "00000000-0000-0000-0000-000000000000")!
    }
    
    func anyTranslation(text: String = "translation", position: TranslationItemPosition? = nil) -> TranslationItem {
        return TranslationItem(
            id: anyTranslationId(),
            text: text,
            position: position
        )
    }
    
    private func anyNewDictionaryItem(suffix: String = "") -> DictionaryItem {
        
        return DictionaryItem(
            id: nil,
            originalText: "originalText" + suffix,
            lemma: "lemma" + suffix,
            language: "English" + suffix,
            translations: [
                anyTranslation(text: "text1" + suffix),
                anyTranslation(text: "text2" + suffix, position: .init(sentenceIndex: 0, textRange: 0..<10))
            ]
        )
    }
    
    private func anyExistingDictonaryItem() -> DictionaryItem {
        
        var item = anyNewDictionaryItem()
        item.id = UUID()
        
        return item
    }
    
    func test_putItem_getItem__new_item() async throws {
        
        let sut = createSUT()
        
        let item = anyNewDictionaryItem()
        
        let putResult = await sut.putItem(item)
        let savedItem = try AssertResultSucceded(putResult)
        
        XCTAssertNotNil(savedItem.id)
        XCTAssertNotNil(savedItem.createdAt)
        XCTAssertNil(savedItem.updatedAt)
        XCTAssertEqual(savedItem.originalText, item.originalText)
        XCTAssertEqual(savedItem.lemma, item.lemma)
        XCTAssertEqual(savedItem.language, item.language)
        XCTAssertEqual(item.translations.count, item.translations.count)
        AssertEqualReadable(item.translations, item.translations)
        
        
        let itemId = savedItem.id!
        
        let getResult = await sut.getItem(id: itemId)
        let receivedItem = try AssertResultSucceded(getResult)
        
        XCTAssertEqual(receivedItem.id, itemId)
        XCTAssertEqual(receivedItem.createdAt, savedItem.createdAt)
        XCTAssertNil(receivedItem.updatedAt)
        XCTAssertEqual(receivedItem.originalText, item.originalText)
        XCTAssertEqual(receivedItem.lemma, item.lemma)
        XCTAssertEqual(receivedItem.language, item.language)
        XCTAssertEqual(receivedItem.translations.count, item.translations.count)
        AssertEqualReadable(receivedItem.translations, item.translations)
    }
    
    func test_putItem__update_not_existing_item() async throws {
        
        let sut = createSUT()
        
        let item = anyExistingDictonaryItem()
        
        let putResult = await sut.putItem(item)
        let error = try AssertResultFailed(putResult)

        guard case .itemNotFound = error else {
            XCTFail("Wrong error type \(error)")
            return
        }
    }
    
    func test_putItem__update_existing_item() async throws {
        
        let sut = createSUT()
        
        let item = anyNewDictionaryItem(suffix: "1")
        
        let putResult = await sut.putItem(item)
        let savedItem = try AssertResultSucceded(putResult)
        
        let itemId = savedItem.id!

        var updatedItemData = anyNewDictionaryItem(suffix: "2")
        updatedItemData.id = itemId
        
        
        let updatedItemResult = await sut.putItem(updatedItemData)
        let updatedItem = try AssertResultSucceded(updatedItemResult)
        
        XCTAssertEqual(updatedItem.id, itemId)
        XCTAssertEqual(updatedItem.createdAt, savedItem.createdAt)
        XCTAssertNotNil(updatedItem.updatedAt)
        XCTAssertEqual(updatedItem.originalText, updatedItemData.originalText)
        XCTAssertEqual(updatedItem.language, updatedItemData.language)
        XCTAssertEqual(updatedItem.translations.count, updatedItemData.translations.count)
        AssertEqualReadable(updatedItem.translations, updatedItemData.translations)
    }
    
    func test_put__only_one_item_with_text_language_pair() async throws {
        
        let sut = createSUT()
        
        let item = anyNewDictionaryItem()
        
        let putResult = await sut.putItem(item)
        try AssertResultSucceded(putResult)
        
        let putResult2 = await sut.putItem(item)
        let error = try AssertResultFailed(putResult2)
        
        guard case .itemMustBeUnique = error else {
            
            XCTFail("Wrong error type \(error)")
            return
        }
    }
    
    func test_deleteItem__not_existing() async throws {
        
        let sut = createSUT()
        
        let deleteResult = await sut.deleteItem(id: UUID())
        let error = try AssertResultFailed(deleteResult)

        guard case .itemNotFound = error else {
            
            XCTFail("Wrong error type \(error)")
            return
        }
    }
    
    func test_deleteItem__existing() async throws {
        
        let sut = createSUT()
        
        let item = anyNewDictionaryItem()
        
        let putResult = await sut.putItem(item)
        let savedItem = try AssertResultSucceded(putResult)
        
        let itemId = savedItem.id!
        
        let deleteResult = await sut.deleteItem(id: itemId)
        try AssertResultSucceded(deleteResult)

        let getResult = await sut.getItem(id: itemId)
        let error = try AssertResultFailed(getResult)
        
        guard case .itemNotFound = error else {
            XCTFail("Wrong error type \(error)")
            return
        }
    }
    
    func test_searchItems__not_existing() async throws {
        
        let sut = createSUT()
        
        let itemsFilters: [DictionaryItemFilter] = [
            .init(lemma: "do"),
            .init(lemma: "you"),
        ]
        
        let result = await sut.searchItems(with: itemsFilters)
        let items = try AssertResultSucceded(result)
        
        XCTAssertTrue(items.isEmpty)
    }
    
    func test_searchItems() async throws {
        
        let sut = createSUT()
        
        let numberOfItems = 10
        let expectedLemmas = ["lemma0", "lemma1"]
        
        let itemsFilters: [DictionaryItemFilter] = [
            .init(lemma: "lemma0"),
            .init(lemma: "lemma1"),
        ]
        
        for index in 0..<numberOfItems {
    
            let dictionaryItem = anyNewDictionaryItem(suffix: String(index))
            let putResult = await sut.putItem(dictionaryItem)
            try AssertResultSucceded(putResult)
        }
        
        let searchResult = await sut.searchItems(with: itemsFilters)
        let items = try AssertResultSucceded(searchResult)
        
        XCTAssertEqual(items.count, expectedLemmas.count)
        
        let receivedLemmas = items.map { $0.lemma }
        AssertEqualReadable(receivedLemmas.sorted(), expectedLemmas.sorted())
    }
    
    func test_listItems__empty_repository() async throws {
        
        let sut = createSUT()
        
        // Given
        // Empty repository
        
        // When
        let result = await sut.listItems()
        let items = try AssertResultSucceded(result)
        
        // Then
        AssertEqualReadable(items.map { $0.id }, [])
    }

    func givenPopulatedRepository(_ sut: SUT) async throws -> [DictionaryItem] {
        
        var items = [DictionaryItem]()
        let numberOfItems = 3
        
        for index in 0..<numberOfItems {
    
            let dictionaryItem = anyNewDictionaryItem(suffix: String(index))
            let putResult = await sut.putItem(dictionaryItem)
            try AssertResultSucceded(putResult)
            
            items.append(dictionaryItem)
        }
        
        return items
    }
    
    func test_listItems__not_empty_repository() async throws {
        
        let sut = createSUT()
        
        // Given
        let dictionaryItems = try await givenPopulatedRepository(sut)
        
        // When
        let result = await sut.listItems()
        let items = try AssertResultSucceded(result)
        
        // Then
        let sortedDictionaryItems = dictionaryItems.sorted { $0.originalText < $1.originalText }
        AssertEqualReadable(
            items.map { $0.id },
            sortedDictionaryItems.map { $0.id }
        )
    }
}
