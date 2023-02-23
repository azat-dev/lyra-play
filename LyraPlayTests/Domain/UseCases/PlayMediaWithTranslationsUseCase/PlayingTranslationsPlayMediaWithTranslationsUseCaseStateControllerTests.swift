//
//  PlayingTranslationsPlayMediaWithTranslationsUseCaseStateControllerTests.swift
//  LyraPlayTests
//
//  Created by Azat Kaiumov on 23.02.23.
//

import Foundation
import XCTest
import Mockingbird
import LyraPlay

class PlayingTranslationsPlayMediaWithTranslationsUseCaseStateControllerImplTests: XCTestCase {
    
    typealias SUT = (
        useCase: PlayingTranslationsPlayMediaWithTranslationsUseCaseStateController,
        delegate: PlayMediaWithTranslationsUseCaseStateControllerDelegateMock,
        playMediaUseCase: PlayMediaWithSubtitlesUseCaseNewMock,
        pronounceTranslationsUseCase: PronounceTranslationsUseCaseMock
    )
    
    // MARK: - Methods
    
    func createSUT(translations: TranslationsToPlayData) -> SUT {
        
        let session = PlayMediaWithTranslationsSession(
            mediaId: UUID(),
            learningLanguage: "English",
            nativeLanguage: "French"
        )
        
        let delegate = mock(PlayMediaWithTranslationsUseCaseStateControllerDelegate.self)
        
        let playMediaUseCase = mock(PlayMediaWithSubtitlesUseCaseNew.self)
        let pronounceTranslationsUseCase = mock(PronounceTranslationsUseCase.self)
        
        let activeSession = PlayMediaWithTranslationsUseCaseStateControllerActiveSession(
            session: session,
            playMediaUseCase: playMediaUseCase,
            provideTranslationsToPlayUseCase: mock(PronounceTranslationsUseCase.self),
            pronounceTranslationsUseCase: pronounceTranslationsUseCase
        )
        
        let useCase = PlayingTranslationsPlayMediaWithTranslationsUseCaseStateController(
            translationsData: translations,
            session: activeSession,
            delegate: delegate
        )
        
        detectMemoryLeak(instance: useCase)
        
        releaseMocks(
            delegate,
            playMediaUseCase,
            pronounceTranslationsUseCase
        )
        
        return (
            useCase,
            delegate,
            playMediaUseCase,
            pronounceTranslationsUseCase
        )
    }
    
    func test_run_single_translations() async throws {
        
        // Given
        let translationData = anyTranslation()
        let translation: TranslationsToPlayData = .single(translation: translationData)
        
        let sut = createSUT(translations: translation)
        
        given(sut.pronounceTranslationsUseCase.pronounceSingle(translation: any()))
            .willReturn(
                .init(unfolding: { .playing(.single(translation: translationData)) } )
            )
        
        given(
            sut.delegate.pronounce(
                translationData: any(),
                session: any()
            )
        ).willReturn(.success(()))
        
        // When
        let result = sut.useCase.run()
        try AssertResultSucceded(result)
        
        // Then
        
        verify(
            sut.pronounceTranslationsUseCase.pronounceSingle(translation: translationData)
        ).wasCalled(1)
    }
    
    // MARK: - Helpers
    
    func anyTranslation() -> SubtitlesTranslationItem {
        return .init(
            dictionaryItemId: UUID(),
            translationId: UUID(),
            originalText: "Apple",
            translatedText: "Яблоко"
        )
    }
}
