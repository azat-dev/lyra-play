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
    
    func testPutGetNewItem() async throws {
        
        let sut = createSUT()
        
        let item = DictionaryItem(
            id: nil,
            originalText: "originalText",
            language: "English"
        )
        
        let putResult = await sut.putItem(item)
        let savedItem = try AssertResultSucceded(putResult)
        
        XCTAssertNotNil(savedItem.id)
        XCTAssertNotNil(savedItem.createdAt)
        XCTAssertNil(savedItem.updatedAt)
        XCTAssertEqual(savedItem.originalText, item.originalText)
        XCTAssertEqual(savedItem.language, item.language)
        
        let itemId = savedItem.id!
        
        let getResult = await sut.getItem(id: itemId)
        let receivedItem = try AssertResultSucceded(getResult)
        
        XCTAssertEqual(receivedItem.id, itemId)
        XCTAssertEqual(receivedItem.createdAt, savedItem.createdAt)
        XCTAssertNil(receivedItem.updatedAt)
        XCTAssertEqual(receivedItem.originalText, item.originalText)
        XCTAssertEqual(receivedItem.language, item.language)
    }
    
    func testUpdateNotExistingItem() async throws {
        
        let sut = createSUT()
        
        let item = DictionaryItem(
            id: UUID(),
            originalText: "originalText",
            language: "English"
        )
        
        let putResult = await sut.putItem(item)
        let error = try AssertResultFailed(putResult)

        guard case .itemNotFound = error else {
            XCTFail("Wrong error type \(error)")
            return
        }
    }
    
    func testUpdatetExistingItem() async throws {
        
        let sut = createSUT()
        
        let item = DictionaryItem(
            id: nil,
            originalText: "originalText",
            language: "English"
        )
        
        let putResult = await sut.putItem(item)
        let savedItem = try AssertResultSucceded(putResult)
        
        let itemId = savedItem.id!

        var updatedItemData = item
        updatedItemData.id = itemId
        updatedItemData.originalText = "updatedText"
        updatedItemData.language = "Japanese"
        
        
        let updatedItemResult = await sut.putItem(updatedItemData)
        let updatedItem = try AssertResultSucceded(updatedItemResult)
        
        XCTAssertEqual(updatedItem.id, itemId)
        XCTAssertEqual(updatedItem.createdAt, savedItem.createdAt)
        XCTAssertNotNil(updatedItem.updatedAt)
        XCTAssertEqual(updatedItem.originalText, updatedItemData.originalText)
        XCTAssertEqual(updatedItem.language, updatedItemData.language)
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
        
        let item = DictionaryItem(
            id: nil,
            originalText: "originalText",
            language: "English"
        )
        
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
}
