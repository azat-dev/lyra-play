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
    
    // MARK: - Helpers
    
    func givenPopulatedRepository(_ sut: SUT) async throws -> [DictionaryItem] {
        
        var items = [DictionaryItem]()
        let numberOfItems = 10
        
        for _ in 0..<numberOfItems {
    
            let dictionaryItem: DictionaryItem = .anyNewDictionaryItem(suffix: UUID().uuidString)
            let putResult = await sut.putItem(dictionaryItem)
            let savedItem = try AssertResultSucceded(putResult)
            
            items.append(savedItem)
        }
        
        return items
    }
    
    // MARK: - Test Methods
    
    func test_putItem_getItem__new_item() async throws {
    
        let sut = createSUT()

        // Given
        let newItem: DictionaryItem = .anyNewDictionaryItem()

        // When
        let putResult = await sut.putItem(newItem)
        
        // Then
        let savedItem = try AssertResultSucceded(putResult)
        
        XCTAssertNotNil(savedItem.id)
        XCTAssertNotNil(savedItem.createdAt)
        XCTAssertNil(savedItem.updatedAt)
        XCTAssertEqual(savedItem.originalText, newItem.originalText)
        XCTAssertEqual(savedItem.lemma, newItem.lemma)
        XCTAssertEqual(savedItem.language, newItem.language)
        XCTAssertEqual(newItem.translations.count, newItem.translations.count)
        AssertEqualReadable(newItem.translations, newItem.translations)
        
        
        // Given
        let itemId = savedItem.id!
        
        // When
        let getResult = await sut.getItem(id: itemId)
        
        // Then
        let receivedItem = try AssertResultSucceded(getResult)
        
        XCTAssertEqual(receivedItem.id, itemId)
        XCTAssertEqual(receivedItem.createdAt, savedItem.createdAt)
        XCTAssertNil(receivedItem.updatedAt)
        XCTAssertEqual(receivedItem.originalText, newItem.originalText)
        XCTAssertEqual(receivedItem.lemma, newItem.lemma)
        XCTAssertEqual(receivedItem.language, newItem.language)
        XCTAssertEqual(receivedItem.translations.count, newItem.translations.count)
        AssertEqualReadable(receivedItem.translations, newItem.translations)
    }
    
    func test_putItem__update_not_existing_item() async throws {
        
        let sut = createSUT()
        
        // Given
        let notExistingItem: DictionaryItem = .anyExistingDictonaryItem()
        
        // When
        let putResult = await sut.putItem(notExistingItem)
        
        // Then
        let error = try AssertResultFailed(putResult)

        guard case .itemNotFound = error else {
            XCTFail("Wrong error type \(error)")
            return
        }
    }
    
    func test_putItem__update_existing_item() async throws {
        
        let sut = createSUT()
        
        // Given
        let existingItems = try await givenPopulatedRepository(sut)
        let existingItem = existingItems.first!
        let itemId = existingItem.id!

        // When
        var updatedItemData = DictionaryItem.anyNewDictionaryItem(suffix: "2")
        updatedItemData.id = itemId
        
        let updatedItemResult = await sut.putItem(updatedItemData)
        
        // Then
        let updatedItem = try AssertResultSucceded(updatedItemResult)
        
        XCTAssertEqual(updatedItem.id, itemId)
        XCTAssertEqual(updatedItem.createdAt, existingItem.createdAt)
        XCTAssertNotNil(updatedItem.updatedAt)
        XCTAssertEqual(updatedItem.originalText, updatedItemData.originalText)
        XCTAssertEqual(updatedItem.language, updatedItemData.language)
        XCTAssertEqual(updatedItem.translations.count, updatedItemData.translations.count)
        AssertEqualReadable(updatedItem.translations, updatedItemData.translations)
    }
    
    func test_put__only_one_item_with_text_language_pair() async throws {
        
        let sut = createSUT()
        
        let item: DictionaryItem = .anyNewDictionaryItem()
        
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
        
        // Given
        let notExistingItemId = UUID()
        
        // When
        let deleteResult = await sut.deleteItem(id: notExistingItemId)

        // Then
        let error = try AssertResultFailed(deleteResult)

        guard case .itemNotFound = error else {
            
            XCTFail("Wrong error type \(error)")
            return
        }
    }
    
    func test_deleteItem__existing() async throws {
        
        let sut = createSUT()
        
        // Given
        let items = try await givenPopulatedRepository(sut)
        
        let existingItem = items.first!
        let existingItemId = existingItem.id!
        
        // When
        let deleteResult = await sut.deleteItem(id: existingItemId)
        try AssertResultSucceded(deleteResult)

        // Then
        let getResult = await sut.getItem(id: existingItemId)
        let error = try AssertResultFailed(getResult)
        
        guard case .itemNotFound = error else {
            XCTFail("Wrong error type \(error)")
            return
        }
    }
    
    func test_searchItems__not_existing() async throws {
        
        // Given
        // Empty repository
        let sut = createSUT()
        
        // When

        let itemsFilters: [DictionaryItemFilter] = [
            .lemma("do"),
            .lemma("you"),
        ]
        let result = await sut.searchItems(with: itemsFilters)

        // Then
        let items = try AssertResultSucceded(result)
        XCTAssertTrue(items.isEmpty)
    }
    
    func test_searchItems() async throws {
        
        // Given
        let sut = createSUT()
        let existingItems = try await givenPopulatedRepository(sut)
        
        let expectedLemmas = [
            existingItems[0].lemma.uppercased(),
            existingItems[1].lemma,
        ]
        let expectedLemmasLowercased = expectedLemmas.map { $0.lowercased() }
        
        let expectedOriginalTexts = [
            existingItems[2].originalText,
            existingItems[3].originalText.uppercased(),
        ]
        let expectedOriginalTextsLowercased = expectedOriginalTexts.map { $0.lowercased() }
        
        
        // When
        var itemsFilters = [DictionaryItemFilter]()
        
        expectedLemmas.forEach { itemsFilters.append(.lemma($0)) }
        expectedOriginalTexts.forEach { itemsFilters.append(.originalText($0)) }
        
        let searchResult = await sut.searchItems(with: itemsFilters)
        let items = try AssertResultSucceded(searchResult)
        
        // Then
        let receivedLemmas = items.map { $0.lemma.lowercased() }
            .filter { expectedLemmasLowercased.contains($0) }
        
        let receivedOriginalTexts = items.map { $0.originalText.lowercased() }
            .filter { expectedOriginalTextsLowercased.contains($0)}
        
        
        // Search by lemma is case insessitive
        AssertEqualReadable(receivedLemmas.sorted(), expectedLemmasLowercased.sorted())
        
        // Search by original text is case insesitive
        AssertEqualReadable(
            receivedOriginalTexts.sorted(),
            expectedOriginalTextsLowercased.sorted()
        )
    }
    
    func test_searchItems__large_condition() async throws {
        
        // Given
        let sut = createSUT()
        let existingItems = try await givenPopulatedRepository(sut)
        
        let expectedLemmas = [
            existingItems[0].lemma.uppercased(),
            existingItems[1].lemma,
        ]
        let expectedLemmasLowercased = expectedLemmas.map { $0.lowercased() }
        
        let expectedOriginalTexts = [
            existingItems[2].originalText,
            existingItems[3].originalText.uppercased(),
        ]
        let expectedOriginalTextsLowercased = expectedOriginalTexts.map { $0.lowercased() }
        
        
        var itemsFilters = [DictionaryItemFilter]()
        expectedLemmas.forEach { itemsFilters.append(.lemma($0)) }
        expectedOriginalTexts.forEach { itemsFilters.append(.originalText($0)) }
        
        for index in 0..<1500 {
            itemsFilters.append(.lemma(UUID().uuidString))
        }
        
        // When
        let searchResult = await sut.searchItems(with: itemsFilters)
        let items = try AssertResultSucceded(searchResult)
        
        // Then
        let receivedLemmas = items.map { $0.lemma.lowercased() }
            .filter { expectedLemmasLowercased.contains($0) }
        
        let receivedOriginalTexts = items.map { $0.originalText.lowercased() }
            .filter { expectedOriginalTextsLowercased.contains($0)}
        
        
        // Search by lemma is case insessitive
        AssertEqualReadable(receivedLemmas.sorted(), expectedLemmasLowercased.sorted())
        
        // Search by original text is case insesitive
        AssertEqualReadable(
            receivedOriginalTexts.sorted(),
            expectedOriginalTextsLowercased.sorted()
        )
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
