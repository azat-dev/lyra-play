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
    
    func test_deleteItem__file() async throws {
        
        let sut = createSUT()
        
        // Given
        let existingMedia = anyFile()
        let mediaId = existingMedia.id
        
        given(await sut.mediaLibraryRepository.getItem(id: mediaId))
            .willReturn(.success(.file(existingMedia)))
        
        given(await sut.mediaLibraryRepository.deleteItem(id: mediaId))
            .willReturn(.success(()))
        given(await sut.mediaFilesRepository.deleteFile(name: existingMedia.file))
            .willReturn(.success(()))
        given(await sut.imagesRepository.deleteFile(name: existingMedia.image!))
            .willReturn(.success(()))
        
        given(await sut.manageSubtitlesUseCase.deleteAllFor(mediaId: mediaId))
            .willReturn(.success(()))
        
        given(await sut.mediaLibraryRepository.getItem(id: mediaId))
            .willReturn(.success(.file(existingMedia)))
        
        // When
        let result = await sut.useCase.deleteItem(id: mediaId)
        try AssertResultSucceded(result)
        
        // Then
        verify(await sut.mediaLibraryRepository.deleteItem(id: mediaId))
            .wasCalled(1)
        verify(await sut.imagesRepository.deleteFile(name: existingMedia.image!))
            .wasCalled(1)
        verify(await sut.mediaFilesRepository.deleteFile(name: existingMedia.file))
            .wasCalled(1)
        verify(await sut.manageSubtitlesUseCase.deleteAllFor(mediaId: mediaId))
            .wasCalled(1)
    }
    
    func test_addFolder() async throws {
        
        let sut = createSUT()
        
        // Given
        let newFolderData = NewMediaLibraryFolderData(
            parentId: UUID(),
            title: "test",
            image: nil
        )
        
        let savedFolderData = MediaLibraryFolder(
            id: UUID(),
            parentId: newFolderData.parentId,
            createdAt: .now,
            updatedAt: nil,
            title: newFolderData.title,
            image: newFolderData.image
        )
        
        given(await sut.mediaLibraryRepository.createFolder(data: newFolderData))
            .willReturn(.success(savedFolderData))
        
        // When
        let result = await sut.useCase.addFolder(data: newFolderData)
        try AssertResultSucceded(result)
        
        // Then
        verify(await sut.mediaLibraryRepository.createFolder(data: newFolderData))
            .wasCalled(1)
    }
    
    func test_addFolder__existing_name() async throws {
        
        let sut = createSUT()
        
        // Given
        let newFolderData = NewMediaLibraryFolderData(
            parentId: UUID(),
            title: "test",
            image: nil
        )
        
        given(await sut.mediaLibraryRepository.createFolder(data: newFolderData))
            .willReturn(.failure(.nameMustBeUnique))
        
        // When
        let result = await sut.useCase.addFolder(data: newFolderData)
        let error = try AssertResultFailed(result)
        
        guard case .nameMustBeUnique = error else {
            XCTFail("Wrong error type \(error)")
            return
        }
    }
}

// MARK: - Helpers

fileprivate extension EditMediaLibraryListUseCaseTests {
    
    private func anyFile() -> MediaLibraryFile {
        
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
}
