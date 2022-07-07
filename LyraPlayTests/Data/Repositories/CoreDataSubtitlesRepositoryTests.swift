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


class CoreDataSubtitlesRepositoryTests: XCTestCase {
    
    func createSUT(file: StaticString = #filePath, line: UInt = #line) -> SubtitlesRepository {

        let storeURL = URL(fileURLWithPath: "/dev/null")
        let coreDataStore = try! CoreDataStore(storeURL: storeURL)
        let subtitlesRepository = CoreDataSubtitlesRepository(coreDataStore: coreDataStore)
        
        detectMemoryLeak(instance: subtitlesRepository, file: file, line: line)
        return subtitlesRepository
    }
    
    private func createTestItem(index: Int) -> SubtitlesInfo {
        
        let mediaFileId = UUID()
        
        return SubtitlesInfo(
            mediaFileId: mediaFileId,
            language: "English",
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
}
