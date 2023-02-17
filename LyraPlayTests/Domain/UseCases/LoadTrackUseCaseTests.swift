//
//  LoadTrackUseCaseTests.swift
//  LyraPlayTests
//
//  Created by Azat Kaiumov on 02.07.22.
//

import Foundation

import XCTest
import LyraPlay

class LoadTrackUseCaseTests: XCTestCase {

//    typealias SUT = (
//        useCase: LoadTrackUseCase,
//        audioFilesRepository: FilesRepositoryMockDeprecated,
//        mediaLibraryRepository: MediaLibraryRepositoryMockDeprecated
//    )
//    
//    func createSUT() -> SUT  {
//        
//        let audioFilesRepository = FilesRepositoryMockDeprecated()
//        let mediaLibraryRepository = MediaLibraryRepositoryMockDeprecated()
//        
//        let useCase = LoadTrackUseCaseImpl(
//            mediaLibraryRepository: mediaLibraryRepository,
//            audioFilesRepository: audioFilesRepository
//        )
//        
//        detectMemoryLeak(instance: useCase)
//        
//        return (
//            useCase,
//            audioFilesRepository,
//            mediaLibraryRepository
//        )
//    }
    
    func testLoadTrack() async throws {
        
//        let (useCase, audioFilesRepository, mediaLibraryRepository) = createSUT()
//
//        let testData = "testdata".data(using: .utf8)!
//        let testName = "test.mp3"
//
//        let testFileInfo = MediaLibraryAudioFile.make(name: "test", duration: 10, audioFile: testName)
//
//        let _ = await audioFilesRepository.putFile(name: testName, data: testData)
//
//        let resultPut = await mediaLibraryRepository.putFile(info: testFileInfo)
//        let savedLibraryItem = try AssertResultSucceded(resultPut)
//
//        let result = await useCase.load(trackId: savedLibraryItem.id!)
//        let trackData = try AssertResultSucceded(result)
//
//        XCTAssertNotNil(trackData)
//        XCTAssertEqual(trackData, testData)
    }
    
    func testLoadTrackWithoutLibraryItem() async throws {
        
//        let (useCase, _, _) = createSUT()
//        
//        let testId = UUID()
//        
//        let result = await useCase.load(trackId: testId)
//        let error = try AssertResultFailed(result)
//        
//        guard case .trackNotFound = error else {
//            XCTFail("Wrong error")
//            return
//        }
    }
}
