//
//  LoadTrackUseCaseTests.swift
//  LyraPlayTests
//
//  Created by Azat Kaiumov on 02.07.22.
//

import Foundation

import XCTest
@testable import LyraPlay

class LoadTrackUseCaseTests: XCTestCase {

    private var audioFilesRepository: FilesRepository!
    private var audioLibraryRepository: AudioLibraryRepository!
    private var useCase: LoadTrackUseCase!
    
    override func setUp() {
        
        audioFilesRepository = FilesRepositoryMock()
        audioLibraryRepository = AudioLibraryRepositoryMock()
        
        useCase = DefaultLoadTrackUseCase(
            audioLibraryRepository: audioLibraryRepository,
            audioFilesRepository: audioFilesRepository
        )
    }
    
    func testLoadTrack() async throws {
        
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
        
        let testId = UUID()
        
        let result = await useCase.load(trackId: testId)
        let error = try AssertResultFailed(result)
        
        guard case .trackNotFound = error else {
            XCTFail("Wrong error")
            return
        }
    }
    
    func testLoadTrackWithoutAudioFile() async throws {
        
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
