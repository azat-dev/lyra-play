//
//  PlayingPlayMediaWithTranslationsUseCaseStateControllerImplTests.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 22.02.2023.
//

import Foundation
import XCTest
import Mockingbird
import LyraPlay

class PlayingPlayMediaWithTranslationsUseCaseStateControllerImplTests: XCTestCase {

    typealias SUT = (
        useCase: PlayingPlayMediaWithTranslationsUseCaseStateController,
        delegate: PlayMediaWithTranslationsUseCaseStateControllerDelegateMock,
        playMediaUseCase: PlayMediaWithSubtitlesUseCaseNewMock,
        provideTranslationsToPlayUseCase: ProvideTranslationsToPlayUseCaseMock,
        session: PlayMediaWithTranslationsSession
    )

    // MARK: - Methods

    func createSUT() -> SUT {
        
        let session = PlayMediaWithTranslationsSession(
            mediaId: UUID(),
            learningLanguage: "English",
            nativeLanguage: "French"
        )

        let delegate = mock(PlayMediaWithTranslationsUseCaseStateControllerDelegate.self)
        
        let playMediaUseCase = mock(PlayMediaWithSubtitlesUseCaseNew.self)
        let provideTranslationsToPlayUseCase = mock(ProvideTranslationsToPlayUseCase.self)
        
        let activeSession = PlayMediaWithTranslationsUseCaseStateControllerActiveSession(
            session: session,
            playMediaUseCase: playMediaUseCase,
            provideTranslationsToPlayUseCase: provideTranslationsToPlayUseCase,
            pronounceTranslationsUseCase: mock(PronounceTranslationsUseCase.self)
        )
        
        let useCase = PlayingPlayMediaWithTranslationsUseCaseStateController(
            session: activeSession,
            delegate: delegate
        )

        detectMemoryLeak(instance: useCase)
        
        releaseMocks(
            delegate,
            playMediaUseCase,
            provideTranslationsToPlayUseCase
        )

        return (
            useCase,
            delegate,
            playMediaUseCase,
            provideTranslationsToPlayUseCase,
            session
        )
    }
    
    func test_run() async throws {
        
        // Given
        let translation = anySingleTranslation()
        
        let sut = createSUT()
        
        given(sut.playMediaUseCase.play())
            .willReturn(.success(()))
        
        given(sut.provideTranslationsToPlayUseCase.getTranslationsToPlay(for: any()))
            .willReturn(translation)
        
        given(
            sut.delegate.pronounce(
                translationData: any(),
                session: any()
            )
        ).willReturn(.success(()))
        
        // When
        let result = sut.useCase.run()
        try AssertResultSucceded(result)
        
        var stopPlaying = false
        
        sut.useCase.playMediaWithSubtitlesUseCaseWillChange(
            from: .sentence(0),
            to: nil,
            stop: &stopPlaying
        )
        
        // Then
        XCTAssertTrue(stopPlaying)
        
        verify(
            sut.delegate.pronounce(
                translationData: translation,
                session: any()
            )
        ).wasCalled(1)
    }
    
    func test_pause() async throws {
        
        // Given
        let sut = createSUT()
        
        given(sut.delegate.pause(session: any()))
            .willReturn(.success(()))
        
        // When
        let result = sut.useCase.pause()
        try AssertResultSucceded(result)
        
        // Then
        verify(sut.delegate.pause(session: any()))
            .wasCalled(1)
    }
    
    func test_togglePlay() async throws {
        
        // Given
        let sut = createSUT()
        
        given(sut.delegate.pause(session: any()))
            .willReturn(.success(()))
        
        // When
        let result = sut.useCase.togglePlay()
        try AssertResultSucceded(result)
        
        // Then
        verify(sut.delegate.pause(session: any()))
            .wasCalled(1)
    }
    
    func test_stop() async throws {
        
        // Given
        let sut = createSUT()
        
        given(sut.delegate.stop(activeSession: any()))
            .willReturn(.success(()))
        
        // When
        let result = sut.useCase.stop()
        try AssertResultSucceded(result)
        
        // Then
        verify(sut.delegate.stop(activeSession: any()))
            .wasCalled(1)
    }
    
    // MARK: - Helpers
    
    func anySingleTranslation() -> TranslationsToPlayData {
        
        return .single(translation: anyTranslation())
    }
    
    func anyTranslation() -> SubtitlesTranslationItem {
        return .init(
            dictionaryItemId: UUID(),
            translationId: UUID(),
            originalText: "Apple",
            translatedText: "Яблоко"
        )
    }
}
