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
        pronounceTranslationsUseCase: PronounceTranslationsUseCaseMock
    )

    // MARK: - Methods

    func createSUT(session: PlayMediaWithTranslationsSession) -> SUT {

        let delegate = mock(PlayMediaWithTranslationsUseCaseStateControllerDelegate.self)
        
        let playMediaUseCase = mock(PlayMediaWithSubtitlesUseCaseNew.self)
        let provideTranslationsToPlayUseCase = mock(ProvideTranslationsToPlayUseCase.self)
        let pronounceTranslationsUseCase = mock(PronounceTranslationsUseCase.self)
        
        let activeSession = PlayMediaWithTranslationsUseCaseStateControllerActiveSession(
            session: session,
            playMediaUseCase: playMediaUseCase,
            provideTranslationsToPlayUseCase: provideTranslationsToPlayUseCase,
            pronounceTranslationsUseCase: pronounceTranslationsUseCase
        )
        
        let useCase = PlayingPlayMediaWithTranslationsUseCaseStateController(
            session: activeSession,
            delegate: delegate
        )

        detectMemoryLeak(instance: useCase)
        
        releaseMocks(
            delegate,
            playMediaUseCase,
            provideTranslationsToPlayUseCase,
            pronounceTranslationsUseCase
        )

        return (
            useCase,
            delegate,
            playMediaUseCase,
            provideTranslationsToPlayUseCase,
            pronounceTranslationsUseCase
        )
    }
    
    func test_run() async throws {
        
        // Given
        
        let session = PlayMediaWithTranslationsSession(
            mediaId: UUID(),
            learningLanguage: "English",
            nativeLanguage: "French"
        )
        
        let translation = anySingleTranslation()
        
        let sut = createSUT(session: session)
        
        given(sut.playMediaUseCase.play())
            .willReturn(.success(()))
        
        given(sut.provideTranslationsToPlayUseCase.getTranslationsToPlay(for: any()))
            .willReturn(translation)
        
        // When
        let result = sut.useCase.run()
        try AssertResultSucceded(result)
        
        // Then
        verify(
            sut.delegate.pronounce(
                translationData: translation,
                session: any()
            )
        ).wasCalled(1)
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
