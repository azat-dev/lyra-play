//
//  PlayingTranslationsPlayMediaWithTranslationsUseCaseStateControllerTests.swift
//  LyraPlayTests
//
//  Created by Azat Kaiumov on 23.02.23.
//

import Foundation
import XCTest
import Mockingbird
import Combine

import LyraPlay

class PlayingTranslationsPlayMediaWithTranslationsUseCaseStateControllerImplTests: XCTestCase {
    
    typealias SUT = (
        useCase: PlayingTranslationsPlayMediaWithTranslationsUseCaseStateController,
        delegate: PlayMediaWithTranslationsUseCaseStateControllerDelegateMock,
        playMediaUseCase: PlayMediaWithSubtitlesUseCaseMock,
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
        
        let playMediaUseCase = mock(PlayMediaWithSubtitlesUseCase.self)
        let pronounceTranslationsUseCase = mock(PronounceTranslationsUseCase.self)
        
        let activeSession = PlayMediaWithTranslationsUseCaseStateControllerActiveSession(
            session: session,
            playMediaUseCase: playMediaUseCase,
            provideTranslationsToPlayUseCase: mock(ProvideTranslationsToPlayUseCase.self),
            pronounceTranslationsUseCase: pronounceTranslationsUseCase
        )
        
        let useCase = PlayingTranslationsPlayMediaWithTranslationsUseCaseStateController(
            translations: translations,
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
        
        let str = CurrentValueSubject<PronounceTranslationsUseCaseState, Never>(.stopped)
        
        let pronounceStream = AsyncThrowingStream<PronounceTranslationsUseCaseState, Error> {
            $0.yield(.playing(.single(translation: translationData)))
            $0.yield(.finished)
            $0.finish()
        }
        
        given(sut.pronounceTranslationsUseCase.pronounceSingle(translation: any()))
            .willReturn(pronounceStream)
        
        given(
            await sut.delegate.pronounce(
                translationData: any(),
                session: any()
            )
        ).willReturn(.success(()))
        
        // When
        let result = await sut.useCase.run()
        try AssertResultSucceded(result)
        
        // Then
        verify(
            sut.pronounceTranslationsUseCase.pronounceSingle(translation: translationData)
        ).wasCalled(1)
        
        verify(
            sut.delegate.didPronounce(session: any())
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
