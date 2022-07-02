//
//  ShowMediaInfoUseCase.swift
//  LyraPlayTests
//
//  Created by Azat Kaiumov on 02.07.22.
//

import Foundation

import XCTest
import LyraPlay

class ShowMediaInfoUseCaseTests: XCTestCase {

    private var useCase: ShowMediaInfoUseCase!
    private var audioLibraryRepository: AudioLibraryRepository!
    private var imagesRepository: FilesRepository!

    override func setUp() async throws {
        
        audioLibraryRepository = AudioFilesRepositoryMock()
        imagesRepository = FilesRepositoryMock()
        
        useCase = ShoMediaInfoUseCase(
            audioLibraryRepository: audioLibraryRepository,
            imagesRepository: imagesRepository
        )
    }
    
    func testSetTrack() throws async {
        
        let testImageData = "image".data(using: .utf8)!
        let testImageName = "test.png"
        
        let putImage = await imagesRepository.putFile(name: testImageName, data: testImageData)
        AssertResultSucceded(putImage)
        
        let testFileInfo = AudioFileInfo()
        let testFileData = "file".data(using: .utf8)!
        
        let putResult = await audioLibraryRepository.putFile(info: testFileInfo, data: testFileData)
        let savedFileInfo = try AssertResultSucceded(putResult)
        
        let initialListenerExpectation = expectation(description: "Initial listener fullfiled")
        let listenerExpectation = expectation(description: "Listener fullfiled")
        
        
        useCase.mediaInfo.observe(on: self) { mediaInfo in
            
            guard let mediaInfo = mediaInfo else {
                initialListenerExpectation.fulfill()
                return
            }
            
            XCTAssertEqual(mediaInfo.image, testImageData)
            XCTAssertEqual(mediaInfo.title, testFileInfo.name)
            XCTAssertEqual(mediaInfo.artist, mediaInfo.artist)
            XCTAssertEqual(mediaInfo.duration, testFileInfo.duration)
            XCTAssertEqual(mediaInfolid, savedFileInfo.id)
            
            listenerExpectation.fulfill()
        }
        
        let mediaInfo = await useCase.setTrack(id: savedFileInfo.id)
        
        XCTAssertNotNil(mediaInfo)
        XCTAssertEqual(mediaInfo.image, testImageData)
        XCTAssertEqual(mediaInfo.title, testFileInfo.name)
        XCTAssertEqual(mediaInfo.artist, mediaInfo.artist)
        XCTAssertEqual(mediaInfo.duration, testFileInfo.duration)
        XCTAssertEqual(mediaInfoid, savedFileInfo.id)
        

        wait(for: [initialListenerExpectation, listenerExpectation], timeout: 3, enforceOrder: true)
    }
}
