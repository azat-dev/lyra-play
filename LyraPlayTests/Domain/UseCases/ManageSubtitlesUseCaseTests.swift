//
//  ManageSubtitlesUseCaseTests.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 15.09.2022.
//

import Foundation
import XCTest
import Mockingbird
import LyraPlay

class ManageSubtitlesUseCaseTests: XCTestCase {
    
    typealias SUT = (
        useCase: ManageSubtitlesUseCase,
        subtitlesRepository: SubtitlesRepositoryMock,
        subtitlesFilesRepository: FilesRepositoryMock
    )
    
    // MARK: - Methods
    
    func createSUT() -> SUT {
        
        let subtitlesRepository = mock(SubtitlesRepository.self)
        let subtitlesFilesRepository = mock(FilesRepository.self)
        
        let useCase = ManageSubtitlesUseCaseImpl(
            subtitlesRepository: subtitlesRepository,
            subtitlesFilesRepository: subtitlesFilesRepository
        )
        
        detectMemoryLeak(instance: useCase)
        
        return (
            useCase: useCase,
            subtitlesRepository: subtitlesRepository,
            subtitlesFilesRepository: subtitlesFilesRepository
        )
    }
    
    func anyLanguage() -> String {
        return "English"
    }
    
    func test_deleteItem__not_exising() async throws {
        
        let sut = createSUT()
        
        // Given
        let notExistingMediaId = UUID()
        let language = anyLanguage()
        
        given(await sut.subtitlesRepository.fetch(mediaFileId: notExistingMediaId, language: language))
            .willReturn(.failure(.itemNotFound))
        
        // When
        let result = await sut.useCase.deleteItem(
            mediaId: notExistingMediaId,
            language: language
        )
        
        // Then
        let error = try AssertResultFailed(result)
        
        guard case .itemNotFound = error else {
            XCTFail("Wrong error type: \(error)")
            return
        }
    }
    
    func test_deleteItem__exising() async throws {
        
        let sut = createSUT()
        
        // Given
        let mediaId = UUID()
        let language = anyLanguage()
        let fileName = "test.lrc"
        
        let subtitleItem = SubtitlesInfo(
            mediaFileId: mediaId,
            language: anyLanguage(),
            file: fileName
        )
        
        given(await sut.subtitlesRepository.fetch(mediaFileId: mediaId, language: language))
            .willReturn(.success(subtitleItem))
        
        given(await sut.subtitlesFilesRepository.deleteFile(name: fileName))
            .willReturn(.success(()))
        
        given(await sut.subtitlesRepository.delete(mediaFileId: mediaId, language: language))
            .willReturn(.success(()))
        
        // When
        let result = await sut.useCase.deleteItem(
            mediaId: mediaId,
            language: language
        )
        try AssertResultSucceded(result)
        
        // Then
        verify(await sut.subtitlesRepository.delete(mediaFileId: mediaId, language: language))
            .wasCalled(1)
        
        verify(await sut.subtitlesFilesRepository.deleteFile(name: fileName))
            .wasCalled(1)
    }
}
