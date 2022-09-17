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
        manageSubtitlesUseCase: ManageSubtitlesUseCaseMock,
        imagesRepository: FilesRepositoryMock
    )

    // MARK: - Methods

    func createSUT() -> SUT {

        let mediaLibraryRepository = mock(MediaLibraryRepository.self)
        let mediaFilesRepository = mock(FilesRepository.self)
        let manageSubtitlesUseCase = mock(ManageSubtitlesUseCase.self)
        let imagesRepository = mock(FilesRepository.self)

        let useCase = EditMediaLibraryListUseCaseImpl(
            mediaLibraryRepository: mediaLibraryRepository,
            mediaFilesRepository: mediaFilesRepository,
            manageSubtitlesUseCase: manageSubtitlesUseCase,
            imagesRepository: imagesRepository
        )

        detectMemoryLeak(instance: useCase)

        return (
            useCase: useCase,
            mediaLibraryRepository: mediaLibraryRepository,
            mediaFilesRepository: mediaFilesRepository,
            manageSubtitlesUseCase: manageSubtitlesUseCase,
            imagesRepository: imagesRepository
        )
    }
    
    func test_deleteItem() async throws {

        let sut = createSUT()

        // Given
        let existingMedia: MediaLibraryItem = .anyExistingItem()
        let mediaId = existingMedia.id!

        given(await sut.mediaLibraryRepository.getInfo(fileId: mediaId))
            .willReturn(.success(existingMedia))

        given(await sut.mediaLibraryRepository.delete(fileId: mediaId))
            .willReturn(.success(()))
        given(await sut.mediaFilesRepository.deleteFile(name: existingMedia.audioFile))
            .willReturn(.success(()))
        given(await sut.imagesRepository.deleteFile(name: existingMedia.coverImage!))
            .willReturn(.success(()))

        given(await sut.manageSubtitlesUseCase.deleteAllFor(mediaId: mediaId))
            .willReturn(.success(()))

        // When
        let result = await sut.useCase.deleteItem(itemId: mediaId)
        try AssertResultSucceded(result)

        // Then
        verify(await sut.mediaLibraryRepository.delete(fileId: mediaId))
            .wasCalled(1)
        verify(await sut.imagesRepository.deleteFile(name: existingMedia.coverImage!))
            .wasCalled(1)
        verify(await sut.mediaFilesRepository.deleteFile(name: existingMedia.audioFile))
            .wasCalled(1)
        verify(await sut.manageSubtitlesUseCase.deleteAllFor(mediaId: mediaId))
            .wasCalled(1)

    }
}
