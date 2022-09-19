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
    
    func test_fetchInfo() async throws {

        let sut = createSUT()

        // Given

        let file = anyFile()
        let testImageData = "image".data(using: .utf8)!

        given(await sut.imagesRepository.getFile(name: file.image!))
            .willReturn(.success(testImageData))
        
        given(await sut.mediaLibraryRepository.getItem(id: file.id))
            .willReturn(.success(.file(file)))

        // When
        let resultMediaInfo = await sut.useCase.fetchInfo(trackId: file.id)
        
        // Then
        let mediaInfo = try AssertResultSucceded(resultMediaInfo)

        XCTAssertNotNil(mediaInfo)
        XCTAssertEqual(mediaInfo.id, file.id.uuidString)
        XCTAssertEqual(mediaInfo.coverImage, testImageData)
        XCTAssertEqual(mediaInfo.title, file.title)
        XCTAssertEqual(mediaInfo.artist, file.subtitle)
        XCTAssertEqual(mediaInfo.duration, file.duration)
    }
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
            subtitle: "subtitle",
            file: "test.mp3",
            duration: 100,
            image: "test.png",
            genre: "rock"
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
