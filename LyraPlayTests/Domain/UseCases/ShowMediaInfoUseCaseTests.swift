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
    private var defaultImage: Data!

    override func setUp() async throws {
        
        audioLibraryRepository = AudioLibraryRepositoryMock()
        imagesRepository = FilesRepositoryMock()
        
        defaultImage = "defaultImage".data(using: .utf8)!
        
        useCase = DefaultShowMediaInfoUseCase(
            audioLibraryRepository: audioLibraryRepository,
            imagesRepository: imagesRepository,
            defaultImage: defaultImage
        )
    }
    
    func testFetch() async throws {
        
        let testImageData = "image".data(using: .utf8)!
        let testImageName = "test.png"
        
        let putImage = await imagesRepository.putFile(name: testImageName, data: testImageData)
        try AssertResultSucceded(putImage)
        
        var testFileInfo = AudioFileInfo.create(name: "TestFile", duration: 10, audioFile: "test.mp3")
        testFileInfo.coverImage = testImageName
        
        let putResult = await audioLibraryRepository.putFile(info: testFileInfo)
        try AssertResultSucceded(putResult)
        
        let savedFileInfo = try AssertResultSucceded(putResult)
        
        let resultMediaInfo = await useCase.fetchInfo(trackId: savedFileInfo.id!)
        let mediaInfo = try AssertResultSucceded(resultMediaInfo)
        
        XCTAssertNotNil(mediaInfo)
        XCTAssertEqual(mediaInfo.id, savedFileInfo.id?.uuidString)
        XCTAssertEqual(mediaInfo.coverImage, testImageData)
        XCTAssertEqual(mediaInfo.title, testFileInfo.name)
        XCTAssertEqual(mediaInfo.artist, mediaInfo.artist)
        XCTAssertEqual(mediaInfo.duration, testFileInfo.duration)
    }
    
    func testFetchDefaultImageIfNoImage() async throws {
        
        let testFileInfo = AudioFileInfo.create(name: "TestFile", duration: 10, audioFile: "test.mp3")
        
        let putResult = await audioLibraryRepository.putFile(info: testFileInfo)
        let savedFileInfo = try AssertResultSucceded(putResult)
        
        let resultMediaInfo = await useCase.fetchInfo(trackId: savedFileInfo.id!)
        let mediaInfo = try AssertResultSucceded(resultMediaInfo)
        
        XCTAssertEqual(mediaInfo.coverImage, defaultImage)
    }
    
    func testFetchDefaultImageIfError() async throws {
        
        var testFileInfo = AudioFileInfo.create(name: "TestFile", duration: 10, audioFile: "test.mp3")
        testFileInfo.coverImage = "someimage.png"
        
        let putResult = await audioLibraryRepository.putFile(info: testFileInfo)
        let savedFileInfo = try AssertResultSucceded(putResult)
        
        let resultMediaInfo = await useCase.fetchInfo(trackId: savedFileInfo.id!)
        let mediaInfo = try AssertResultSucceded(resultMediaInfo)
        
        XCTAssertEqual(mediaInfo.coverImage, defaultImage)
    }
    
    func testFetchTrackDoesntExist() async throws {
        

        let trackId = UUID()
        
        let resultMediaInfo = await useCase.fetchInfo(trackId: trackId)
        let error = try AssertResultFailed(resultMediaInfo)
        
        guard case .trackNotFound = error else {
            XCTFail("Wrong error")
            return
        }
    }
}
