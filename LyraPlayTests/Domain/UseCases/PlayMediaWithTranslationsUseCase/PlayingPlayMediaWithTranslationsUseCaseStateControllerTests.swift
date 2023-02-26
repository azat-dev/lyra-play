//
//  PlayingPlayMediaWithTranslationsUseCaseStateControllerImplTests.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 22.02.2023.
//

import Foundation
import XCTest
import Combine
import Mockingbird
import LyraPlay

class PlayingPlayMediaWithTranslationsUseCaseStateControllerImplTests: XCTestCase {

    typealias SUT = (
        useCase: PlayingPlayMediaWithTranslationsUseCaseStateController,
        delegate: PlayMediaWithTranslationsUseCaseStateControllerDelegateMock,
        playMediaUseCase: PlayMediaWithSubtitlesUseCaseMock,
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

        let playMediaUseCase = mock(PlayMediaWithSubtitlesUseCase.self)
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

        let pronounceExpectation = expectation(description: "Pronounce")
        
        given(
            await sut.delegate.pronounce(
                translationData: any(),
                session: any()
            )
        ).will { translationData, _ in
            
            if translationData == translation {
                pronounceExpectation.fulfill()
            }
            return .success(())
        }
        
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
        
        verify(sut.delegate.didStartPlaying(withController: any()))
            .wasCalled(1)
        
//        verify(
//            await sut.delegate.pronounce(
//                translationData: translation,
//                session: any()
//            )
//        ).wasCalled(1)
        
        wait(for: [pronounceExpectation], timeout: 1)
    }
    
    func test_pause() async throws {
        
        // Given
        let sut = createSUT()
        
        given(sut.delegate.pause(elapsedTime: any(), session: any()))
            .willReturn(.success(()))
        
        // When
        let result = sut.useCase.pause()
        try AssertResultSucceded(result)
        
        // Then
        verify(sut.delegate.pause(elapsedTime: any(), session: any()))
            .wasCalled(1)
    }
    
    func test_togglePlay() async throws {
        
        // Given
        let sut = createSUT()
        
        given(sut.delegate.pause(elapsedTime: any(), session: any()))
            .willReturn(.success(()))
        
        // When
        let result = sut.useCase.togglePlay()
        try AssertResultSucceded(result)
        
        // Then
        verify(sut.delegate.pause(elapsedTime: any(), session: any()))
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
