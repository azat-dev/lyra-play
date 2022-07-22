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
    
    func createSUT(file: StaticString = #filePath, line: UInt = #line) -> DictionaryRepository{

        let storeURL = URL(fileURLWithPath: "/dev/null")
        let coreDataStore = try! CoreDataStore(storeURL: storeURL)
        let repository = CoreDataDictionaryRepository(coreDataStore: coreDataStore)
        
        detectMemoryLeak(instance: repository, file: file, line: line)
        return repository
    }
    
    func anyTranslation(text: String = "translation") -> TranslationItem {
        return TranslationItem(
            text: text
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
                anyTranslation(text: "text2" + suffix)
            ]
        )
    }
    
    private func anyExistingDictonaryItem() -> DictionaryItem {
        
        var item = anyNewDictionaryItem()
        item.id = UUID()
        
        return item
    }
    
    func testPutGetNewItem() async throws {
        
        let sut = createSUT()
        
        let item = anyNewDictionaryItem()
        
        let putResult = await sut.putItem(item)
        let savedItem = try AssertResultSucceded(putResult)
        
        XCTAssertNotNil(savedItem.id)
        XCTAssertNotNil(savedItem.createdAt)
        XCTAssertNil(savedItem.updatedAt)
        XCTAssertEqual(savedItem.originalText, item.originalText)
        XCTAssertEqual(savedItem.language, item.language)
        XCTAssertEqual(item.translations.count, item.translations.count)
        XCTAssertEqual(item.translations, item.translations)
        
        let itemId = savedItem.id!
        
        let getResult = await sut.getItem(id: itemId)
        let receivedItem = try AssertResultSucceded(getResult)
        
        XCTAssertEqual(receivedItem.id, itemId)
        XCTAssertEqual(receivedItem.createdAt, savedItem.createdAt)
        XCTAssertNil(receivedItem.updatedAt)
        XCTAssertEqual(receivedItem.originalText, item.originalText)
        XCTAssertEqual(receivedItem.language, item.language)
        XCTAssertEqual(receivedItem.translations.count, item.translations.count)
        XCTAssertEqual(receivedItem.translations, item.translations)
    }
    
    func testUpdateNotExistingItem() async throws {
        
        let sut = createSUT()
        
        let item = anyExistingDictonaryItem()
        
        let putResult = await sut.putItem(item)
        let error = try AssertResultFailed(putResult)

        guard case .itemNotFound = error else {
            XCTFail("Wrong error type \(error)")
            return
        }
    }
    
    func testUpdateExistingItem() async throws {
        
        let sut = createSUT()
        
        let item = anyNewDictionaryItem()
        
        let putResult = await sut.putItem(item)
        let savedItem = try AssertResultSucceded(putResult)
        
        let itemId = savedItem.id!

        var updatedItemData = item
        updatedItemData.id = itemId
        updatedItemData.originalText = "updatedText"
        updatedItemData.language = "Japanese"
        updatedItemData.translations = [
            anyTranslation(text: "1"),
            anyTranslation(text: "2"),
        ]
        
        
        let updatedItemResult = await sut.putItem(updatedItemData)
        let updatedItem = try AssertResultSucceded(updatedItemResult)
        
        XCTAssertEqual(updatedItem.id, itemId)
        XCTAssertEqual(updatedItem.createdAt, savedItem.createdAt)
        XCTAssertNotNil(updatedItem.updatedAt)
        XCTAssertEqual(updatedItem.originalText, updatedItemData.originalText)
        XCTAssertEqual(updatedItem.language, updatedItemData.language)
        XCTAssertEqual(updatedItem.translations.count, updatedItemData.translations.count)
        XCTAssertEqual(updatedItem.translations, updatedItemData.translations)
    }
    
    func testOnlyOneItemWithTextLanguagePair() async throws {
        
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
    
    func testDeleteNotExistingItem() async throws {
        
        let sut = createSUT()
        
        let deleteResult = await sut.deleteItem(id: UUID())
        let error = try AssertResultFailed(deleteResult)

        guard case .itemNotFound = error else {
            
            XCTFail("Wrong error type \(error)")
            return
        }
    }
    
    func testDeleteExistingItem() async throws {
        
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
    
    func testSearchNotExistingItems() async throws {
        
        let sut = createSUT()
        
        let itemsFilters: [DictionaryItemFilter] = [
            .init(lemma: "do"),
            .init(lemma: "you"),
        ]
        
        let items = await sut.searchItems(with: itemsFilters)
        
        XCTAssertTrue(items.isEmpty)
    }
    
    func testSearchItems() async throws {
        
        let sut = createSUT()
        
        let numberOfItems = 3
        let expectedLemmas = ["lemma0", "lemma1"]
        
        let itemsFilters: [DictionaryItemFilter] = [
            .init(lemma: "do"),
            .init(lemma: "you"),
        ]
        
        for index in 0..<numberOfItems {
    
            let dictionaryItem = anyNewDictionaryItem(suffix: String(index))
            let putResult = await sut.putItem(dictionaryItem)
            try AssertResultSucceded(putResult)
        }
        
        
        let searchResult = await sut.searchItems(lemmas: expectedLemmas)
        let items = try AssertResultSucceded(searchResult)
        
        XCTAssertEqual(items.count, expectedLemmas)
        
        let receivedLemmas = items.keys.map { $0.lemma }
        XCTAssertEqual(receivedLemmas, expectedLemmas.sorted())
    }
}
