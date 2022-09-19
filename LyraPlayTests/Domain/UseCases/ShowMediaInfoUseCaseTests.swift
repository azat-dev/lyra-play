//
//  ShowMediaInfoUseCase.swift
//  LyraPlayTests
//
//  Created by Azat Kaiumov on 02.07.22.
//

import Foundation

import XCTest
import LyraPlay
import Mockingbird

class ShowMediaInfoUseCaseTests: XCTestCase {
    
    typealias SUT = (
        useCase: ShowMediaInfoUseCase,
        mediaLibraryRepository: MediaLibraryRepositoryMock,
        imagesRepository: FilesRepositoryMock,
        defaultImage: Data
    )
    
    func createSUT() -> SUT {
        
        let mediaLibraryRepository = mock(MediaLibraryRepository.self)
        let imagesRepository = mock(FilesRepository.self)
        
        let defaultImage = "defaultImage".data(using: .utf8)!
        
        let useCase = ShowMediaInfoUseCaseImpl(
            mediaLibraryRepository: mediaLibraryRepository,
            imagesRepository: imagesRepository,
            defaultImage: defaultImage
        )
        
        detectMemoryLeak(instance: useCase)
        
        return (
            useCase,
            mediaLibraryRepository,
            imagesRepository,
            defaultImage
        )
    }
    
//    func testFetch() async throws {
//
//        let (
//            useCase,
//            mediaLibraryRepository,
//            imagesRepository,
//            _
//        ) = createSUT()
//
//        let testImageData = "image".data(using: .utf8)!
//        let testImageName = "test.png"
//
//        let putImage = await imagesRepository.putFile(name: testImageName, data: testImageData)
//        try AssertResultSucceded(putImage)
//
//        var testFileInfo = MediaLibraryAudioFile.create(name: "TestFile", duration: 10, audioFile: "test.mp3")
//        testFileInfo.coverImage = testImageName
//
//        let putResult = await mediaLibraryRepository.putFile(info: testFileInfo)
//        try AssertResultSucceded(putResult)
//
//        let savedFileInfo = try AssertResultSucceded(putResult)
//
//        let resultMediaInfo = await useCase.fetchInfo(trackId: savedFileInfo.id!)
//        let mediaInfo = try AssertResultSucceded(resultMediaInfo)
//
//        XCTAssertNotNil(mediaInfo)
//        XCTAssertEqual(mediaInfo.id, savedFileInfo.id?.uuidString)
//        XCTAssertEqual(mediaInfo.coverImage, testImageData)
//        XCTAssertEqual(mediaInfo.title, testFileInfo.name)
//        XCTAssertEqual(mediaInfo.artist, mediaInfo.artist)
//        XCTAssertEqual(mediaInfo.duration, testFileInfo.duration)
//    }
//
//    func testFetchDefaultImageIfNoImage() async throws {
//
//        let (
//            useCase,
//            mediaLibraryRepository,
//            _,
//            defaultImage
//        ) = createSUT()
//
//        let testFileInfo = MediaLibraryAudioFile.create(name: "TestFile", duration: 10, audioFile: "test.mp3")
//
//        let putResult = await mediaLibraryRepository.putFile(info: testFileInfo)
//        let savedFileInfo = try AssertResultSucceded(putResult)
//
//        let resultMediaInfo = await useCase.fetchInfo(trackId: savedFileInfo.id!)
//        let mediaInfo = try AssertResultSucceded(resultMediaInfo)
//
//        XCTAssertEqual(mediaInfo.coverImage, defaultImage)
//    }
//
//    func testFetchDefaultImageIfError() async throws {
//
//        let (
//            useCase,
//            mediaLibraryRepository,
//            _,
//            defaultImage
//        ) = createSUT()
//
//        var testFileInfo = MediaLibraryAudioFile.create(name: "TestFile", duration: 10, audioFile: "test.mp3")
//        testFileInfo.coverImage = "someimage.png"
//
//        let putResult = await mediaLibraryRepository.putFile(info: testFileInfo)
//        let savedFileInfo = try AssertResultSucceded(putResult)
//
//        let resultMediaInfo = await useCase.fetchInfo(trackId: savedFileInfo.id!)
//        let mediaInfo = try AssertResultSucceded(resultMediaInfo)
//
//        XCTAssertEqual(mediaInfo.coverImage, defaultImage)
//    }
    
    func anyFile() -> MediaLibraryFile {
        
        return .init(
            id: UUID(),
            parentId: nil,
            createdAt: .now,
            updatedAt: nil,
            title: "test",
            subtitle: nil,
            file: "test.mp3",
            duration: 100,
            image: nil,
            genre: nil
        )
    }
    
    func test_fetchInfo__not_exist() async throws {
        
        let sut = createSUT()
        
        // Given
        let fileId = UUID()
        
        given(await sut.mediaLibraryRepository.getItem(id: fileId))
            .willReturn(.failure(.fileNotFound))
        
        // When
        let resultMediaInfo = await sut.useCase.fetchInfo(trackId: fileId)
        
        // Then
        let error = try AssertResultFailed(resultMediaInfo)
        
        guard case .trackNotFound = error else {
            XCTFail("Wrong error ")
            return
        }
    }
}
