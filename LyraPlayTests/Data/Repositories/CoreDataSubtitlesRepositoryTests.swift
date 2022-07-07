//
//  CoreDataSubtitlesRepositoryTests.swift
//  LyraPlayTests
//
//  Created by Azat Kaiumov on 06.07.22.
//

import XCTest
import LyraPlay
import CoreData

extension SubtitlesInfo: Equatable {
    
    public static func == (lhs: SubtitlesInfo, rhs: SubtitlesInfo) -> Bool {
        return lhs.language == rhs.language &&
            lhs.mediaFileId == rhs.mediaFileId &&
            lhs.file == rhs.file
    }
}

extension SubtitlesInfo: Comparable {
    public static func < (lhs: SubtitlesInfo, rhs: SubtitlesInfo) -> Bool {
        
        if lhs == rhs {
            return false
        }

        if lhs.mediaFileId.uuidString > rhs.mediaFileId.uuidString {
            return true
        }

        if lhs.language > rhs.language {
            return true
        }

        if lhs.file > rhs.file {
            return true
        }
        
        return false
    }
}


class CoreDataSubtitlesRepositoryTests: XCTestCase {
    
    func createSUT(file: StaticString = #filePath, line: UInt = #line) -> SubtitlesRepository {

        let storeURL = URL(fileURLWithPath: "/dev/null")
        let coreDataStore = try! CoreDataStore(storeURL: storeURL)
        let subtitlesRepository = CoreDataSubtitlesRepository(coreDataStore: coreDataStore)
        
        detectMemoryLeak(instance: subtitlesRepository, file: file, line: line)
        return subtitlesRepository
    }
    
    private func createTestItem(index: Int, language: String = "English") -> SubtitlesInfo {
        
        let mediaFileId = UUID()
        
        return SubtitlesInfo(
            mediaFileId: mediaFileId,
            language: language,
            file: "test\(index).lrc"
        )
    }

    func testPutFetch() async throws {
        
        let subtitlesRepository = createSUT()

        let testItem1 = createTestItem(index: 0)

        let putResult = await subtitlesRepository.put(info: testItem1)
        try AssertResultSucceded(putResult)
        
        let fetchResult = await subtitlesRepository.fetch(
            mediaFileId: testItem1.mediaFileId,
            language: testItem1.language
        )
        
        let receivedItem = try AssertResultSucceded(fetchResult)
        
        let unwrappedItem = try XCTUnwrap(receivedItem)
        XCTAssertEqual(unwrappedItem, testItem1)
    }
    
    func testListEmptyRecords() async throws {
        
        let subtitlesRepository = createSUT()

        let mediaId = UUID()
        let listResult = await subtitlesRepository.list(mediaFileId: mediaId)
        let items = try AssertResultSucceded(listResult)
        
        XCTAssertEqual(items, [])
    }
    
    func testListRecords() async throws {
        
        let subtitlesRepository = createSUT()

        let testItem1 = createTestItem(index: 0)
        let testItem2 = createTestItem(index: 1)
        var testItem3 = createTestItem(index: 2, language: "French")
        testItem3.mediaFileId = testItem1.mediaFileId
        
        let _ = await subtitlesRepository.put(info: testItem1)
        let _ = await subtitlesRepository.put(info: testItem2)
        let _ = await subtitlesRepository.put(info: testItem3)
        
        
        let listResult1 = await subtitlesRepository.list(mediaFileId: testItem1.mediaFileId)
        let items1 = try AssertResultSucceded(listResult1)
        
        XCTAssertEqual(items1.sorted(), [testItem1, testItem3].sorted())
        
        let listResult2 = await subtitlesRepository.list(mediaFileId: testItem2.mediaFileId)
        let items2 = try AssertResultSucceded(listResult2)
        
        XCTAssertEqual(items2.sorted(), [testItem2].sorted())
    }
    
    func testListAllRecords() async throws {
        
        let subtitlesRepository = createSUT()

        let testItem1 = createTestItem(index: 0)
        let testItem2 = createTestItem(index: 1)
        let testItem3 = createTestItem(index: 2)
        
        let _ = await subtitlesRepository.put(info: testItem1)
        let _ = await subtitlesRepository.put(info: testItem2)
        let _ = await subtitlesRepository.put(info: testItem3)
        
        
        let listResult = await subtitlesRepository.list()
        let items = try AssertResultSucceded(listResult)
        
        XCTAssertEqual(items.sorted(), [testItem1, testItem2, testItem3].sorted())
    }

    func testPutAllowMultipleRecordsWithDifferentLanguages() async throws {
        
        let sut = createSUT()
        
        let item1 = createTestItem(index: 0, language: "English")
        let item2 = createTestItem(index: 1)
        var item3 = createTestItem(index: 1, language: "French")
        item3.mediaFileId = item1.mediaFileId
        
        let result1 = await sut.put(info: item1)
        try AssertResultSucceded(result1)
        
        let result2 = await sut.put(info: item2)
        try AssertResultSucceded(result2)

        let result3 = await sut.put(info: item3)
        try AssertResultSucceded(result3)
        
        let listResult = await sut.list()
        let list = try AssertResultSucceded(listResult)

        let expectedItems = [item1, item2, item3]
        XCTAssertEqual(list.count, expectedItems.count)
        XCTAssertEqual(list.sorted(), expectedItems.sorted())
    }
    
    func testPutAllowOnlyOneRecordWithUniqueMediaIdLanguagePair() async throws {
        
        let sut = createSUT()
        
        let item1 = createTestItem(index: 0, language: "English")
        let item2 = createTestItem(index: 1)
        var item3 = createTestItem(index: 1, language: "English")
        item3.mediaFileId = item1.mediaFileId
        
        let result1 = await sut.put(info: item1)
        try AssertResultSucceded(result1)
        
        let result2 = await sut.put(info: item2)
        try AssertResultSucceded(result2)

        let result3 = await sut.put(info: item3)
        try AssertResultSucceded(result3)
        
        let listResult = await sut.list()
        let list = try AssertResultSucceded(listResult)

        let expectedItems = [item3, item2]
        XCTAssertEqual(list.count, expectedItems.count)
        XCTAssertEqual(list.sorted(), expectedItems.sorted())
    }
}
