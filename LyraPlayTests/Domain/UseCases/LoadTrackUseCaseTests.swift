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

    typealias SUT = (
        useCase: LoadTrackUseCase,
        audioFilesRepository: FilesRepositoryMock,
        audioLibraryRepository: AudioLibraryRepositoryMock
    )
    
    func createSUT() -> SUT  {
        
        let audioFilesRepository = FilesRepositoryMock()
        let audioLibraryRepository = AudioLibraryRepositoryMock()
        
        let useCase = LoadTrackUseCaseImpl(
            audioLibraryRepository: audioLibraryRepository,
            audioFilesRepository: audioFilesRepository
        )
        
        detectMemoryLeak(instance: useCase)
        
        return (
            useCase,
            audioFilesRepository,
            audioLibraryRepository
        )
    }
    
    func testLoadTrack() async throws {
        
        let (useCase, audioFilesRepository, audioLibraryRepository) = createSUT()
        
        let testData = "testdata".data(using: .utf8)!
        let testName = "test.mp3"
        
        let testFileInfo = AudioFileInfo.create(name: "test", duration: 10, audioFile: testName)
        
        let _ = await audioFilesRepository.putFile(name: testName, data: testData)
        
        let resultPut = await audioLibraryRepository.putFile(info: testFileInfo)
        let savedLibraryItem = try AssertResultSucceded(resultPut)
        
        let result = await useCase.load(trackId: savedLibraryItem.id!)
        let trackData = try AssertResultSucceded(result)
        
        XCTAssertNotNil(trackData)
        XCTAssertEqual(trackData, testData)
    }
    
    func testLoadTrackWithoutLibraryItem() async throws {
        
        let (useCase, _, _) = createSUT()
        
        let testId = UUID()
        
        let result = await useCase.load(trackId: testId)
        let error = try AssertResultFailed(result)
        
        guard case .trackNotFound = error else {
            XCTFail("Wrong error")
            return
        }
    }
    
    func testLoadTrackWithoutAudioFile() async throws {
        
        let (useCase, _, audioLibraryRepository) = createSUT()
        
        let testName = "test.mp3"
        
        let testFileInfo = AudioFileInfo.create(name: "test", duration: 10, audioFile: testName)
        
        let resultPut = await audioLibraryRepository.putFile(info: testFileInfo)
        let savedLibraryItem = try AssertResultSucceded(resultPut)
        
        let result = await useCase.load(trackId: savedLibraryItem.id!)
        let error = try AssertResultFailed(result)
        
        guard case .trackNotFound = error else {
            XCTFail("Wrong error")
            return
        }
    }
}
