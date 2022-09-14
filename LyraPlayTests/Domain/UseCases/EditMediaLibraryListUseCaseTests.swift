//
//  EditMediaLibraryListUseCaseTests.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 14.09.2022.
//

import Foundation
import XCTest
import Mockingbird
import LyraPlay

class EditMediaLibraryListUseCaseTests: XCTestCase {

    typealias SUT = (
        useCase: EditMediaLibraryListUseCase,
        mediaLibraryRepository: MediaLibraryRepositoryMock,
        mediaFilesRepository: FilesRepositoryMock,
        subtitlesRepository: SubtitlesRepositoryMock,
        imagesRepository: FilesRepositoryMock
    )

    // MARK: - Methods

    func createSUT() -> SUT {

        let mediaLibraryRepository = MediaLibraryRepositoryMock()
        let mediaFilesRepository = FilesRepositoryMock()
        let subtitlesRepository = SubtitlesRepositoryMock()
        let imagesRepository = FilesRepositoryMock()

        let useCase = EditMediaLibraryListUseCaseImpl(
            mediaLibraryRepository: mediaLibraryRepository,
            mediaFilesRepository: mediaFilesRepository,
            subtitlesRepository: subtitlesRepository,
            imagesRepository: imagesRepository
        )

        detectMemoryLeak(instance: useCase)

        return (
            useCase: useCase,
            mediaLibraryRepository: mediaLibraryRepository,
            mediaFilesRepository: mediaFilesRepository,
            subtitlesRepository: subtitlesRepository,
            imagesRepository: imagesRepository
        )
    }
    
    func test_deleteItem__not_existing() async throws {

        let sut = createSUT()

        // Given
        let notExistingItemId = UUID()
        
//        given(await sut.mediaLibraryRepository.delete(fileId: notExistingItemId))
//            .willReturn(.failure(.itemNotFound))

        // When
        let result = await sut.useCase.deleteItem(itemId: notExistingItemId)

        // Then
        let error = try AssertResultFailed(result)
        
        guard case .itemNotFound = error else {
            
            XCTFail("Wrong error type: \(error)")
            return
        }
    }
    
    func test_deleteItem() async throws {

        let sut = createSUT()

        // Given
        
        let mediaId = UUID()
        let mediaFileName = "test.mp3"
        let imageFileName = "test.png"
        
        let existingItem = AudioFileInfo(
            id: mediaId,
            createdAt: nil,
            updatedAt: nil,
            name: "Test",
            duration: 1,
            audioFile: mediaFileName,
            artist: nil,
            genre: nil,
            coverImage: imageFileName
        )
        
//        given(sut.mediaLibraryRepository.delete(fileId: mediaId))
//            .willReturn(.success(()))
//
//        given(sut.mediaFilesRepository.deleteFile(name: mediaFileName))
//            .willReturn(.success(()))
//
//        given(sut.imagesRepository.deleteFile(name: imageFileName))
//            .willReturn(.success(()))
//
//        given(sut.subtitlesRepository.delete(mediaFileId: mediaId, language: "English"))
//            .willReturn(.success(()))
//
//        // When
//        let result = await sut.useCase.deleteItem(itemId: existingItem.id!)
        

        // Then
//        verify(await sut.mediaLibraryRepository.delete(fileId: existingItem.id!))
//            .wasCalled(1)
//
//        verify(await sut.mediaFilesRepository.deleteFile(name: fileName))
//            .wasCalled(1)
//
//        verify(await sut.imagesRepository.deleteFile(name: imageFileName))
//            .wasCalled(1)
//
//        verify(await sut.subtitlesRepository.delete(mediaFileId: mediaId, language: "English"))
//            .wasCalled(1)

    }

}
