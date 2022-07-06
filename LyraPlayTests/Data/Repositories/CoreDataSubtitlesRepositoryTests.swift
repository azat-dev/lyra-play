//
//  CoreDataSubtitlesRepositoryTests.swift
//  LyraPlayTests
//
//  Created by Azat Kaiumov on 06.07.22.
//

import XCTest
import LyraPlay
import CoreData


class CoreDataSubtitlesRepositoryTests: XCTestCase {
    
    func createSUT(file: StaticString = #filePath, line: UInt = #line) -> SubtitlesRepository {

        let storeURL = URL(fileURLWithPath: "/dev/null")
        let coreDataStore = try! CoreDataStore(storeURL: storeURL)
        let subtitlesRepository = CoreDataSubtitlesRepository(coreDataStore: coreDataStore)
        
        detectMemoryLeak(instance: subtitlesRepository, file: file, line: line)
        return subtitlesRepository
    }

    func testAttachToNotExistingFile() async throws {
        
        let subtitlesRepository = createSUT()

        let mediaFileId = UUID()
        
        let subtitlesInfo = SubtitlesAttachment(
            id: nil,
            createdAt: nil,
            updatedAt: nil,
            mediaFileId: mediaFileId,
            language: "English",
            file: "test.lrc"
        )
        
        
        let result = await subtitlesRepository.put(info: subtitlesInfo)
        let error = try AssertResultFailed(result)
        
        guard case .mediaFileNotFound = error else {
            XCTFail("Wrong error type: \(error)")
        }
    }
}
