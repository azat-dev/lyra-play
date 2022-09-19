//
//  BrowseMediaLibraryUseCaseTests.swift
//  LyraPlayTests
//
//  Created by Azat Kaiumov on 27.06.22.
//

import XCTest
import Mockingbird
import LyraPlay

class BrowseMediaLibraryUseCaseTests: XCTestCase {

    typealias SUT = (
        useCase: BrowseMediaLibraryUseCase,
        mediaLibraryRepository: MediaLibraryRepositoryMock,
        imagesRepository: FilesRepositoryMock
    )

    func createSUT() -> SUT {
        
        let mediaLibraryRepository = mock(MediaLibraryRepository.self)
        let imagesRepository = mock(FilesRepository.self)
        
        let useCase = BrowseMediaLibraryUseCaseImpl(
            mediaLibraryRepository: mediaLibraryRepository,
            imagesRepository: imagesRepository
        )
        
        detectMemoryLeak(instance: useCase)
        
        return (
            useCase,
            mediaLibraryRepository,
            imagesRepository
        )
    }
    
    private func getTestFile(index: Int) -> (info: MediaLibraryAudioFile, data: Data) {
        return (
            info: MediaLibraryAudioFile.create(name: "Test \(index)", duration: 10, audioFile: "test.mp3"),
            data: "Test \(index)".data(using: .utf8)!
        )
    }
    
    private func anyFolder() -> MediaLibraryFolder {
        
        return .init(
            id: UUID(),
            parentId: nil,
            createdAt: .now,
            updatedAt: nil,
            title: "test",
            image: nil
        )
    }
    
    func test_list__items() async throws {

        let sut = createSUT()

        // Given
        let folderId = UUID()
        
        let exisingItems: [MediaLibraryItem] = [
            .folder(anyFolder()),
            .folder(anyFolder())
        ]

        given(await sut.mediaLibraryRepository.listItems(folderId: folderId))
            .willReturn(.success(exisingItems))
        
        // When
        let result = await sut.useCase.listItems(folderId: folderId)
        
        // Then
        let receivedItems = try AssertResultSucceded(result)
        
        AssertEqualReadable(receivedItems, exisingItems)
    }

    func test_getItem__existing() async throws {

        let sut = createSUT()

        // Given
        let existingFolder = anyFolder()
        
        given(await sut.mediaLibraryRepository.getItem(id: existingFolder.id))
            .willReturn(.success(.folder(existingFolder)))
        
        // When
        let result = await sut.useCase.getItem(id: existingFolder.id)
        
        // Then
        let receivedItem = try AssertResultSucceded(result)
        AssertEqualReadable(receivedItem, .folder(existingFolder))
    }
    
    func test_getItem__not_existing() async throws {
        
        let sut = createSUT()
        
        // Given
        given(await sut.mediaLibraryRepository.getItem(id: any()))
            .willReturn(.failure(.fileNotFound))
        
        // When
        let infoResult = await sut.useCase.getItem(id: UUID())
        
        // Then
        XCTAssertEqual(infoResult, .failure(.fileNotFound))
    }
    
//    func testFetchImage() async throws {
//
//        let (useCase, _, imagesRepository) = createSUT()
//
//        let testImageName1 = "image1.png"
//        let testImageName2 = "image2.jpeg"
//
//        let testImage1 = "image1".data(using: .utf8)!
//        let testImage2 = "image2".data(using: .utf8)!
//
//        let put1 = await imagesRepository.putFile(name: testImageName1, data: testImage1)
//        try AssertResultSucceded(put1)
//
//        let put2 = await imagesRepository.putFile(name: testImageName2, data: testImage2)
//        try AssertResultSucceded(put2)
//
//        let resultImage1 = await useCase.fetchImage(name: testImageName1)
//        let imageData1 = try AssertResultSucceded(resultImage1)
//
//        XCTAssertEqual(imageData1, testImage1)
//
//        let resultImage2 = await useCase.fetchImage(name: testImageName2)
//        let imageData2 = try AssertResultSucceded(resultImage2)
//
//        XCTAssertEqual(imageData2, testImage2)
//    }
}
