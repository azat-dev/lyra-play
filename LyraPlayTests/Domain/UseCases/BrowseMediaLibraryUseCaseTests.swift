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
    
    func testFetchImage() async throws {

        let sut = createSUT()

        // Given
        let testImageName1 = "image1.png"
        let testImage1 = "image1".data(using: .utf8)!

        given(await sut.imagesRepository.getFile(name: testImageName1))
            .willReturn(.success(testImage1))

        // When
        let resultImage1 = await sut.useCase.fetchImage(name: testImageName1)
        let imageData1 = try AssertResultSucceded(resultImage1)

        // Then
        XCTAssertEqual(imageData1, testImage1)
    }
}
