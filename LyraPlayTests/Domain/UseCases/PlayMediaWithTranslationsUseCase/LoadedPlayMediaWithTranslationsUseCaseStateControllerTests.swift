//
//  LoadedPlayMediaWithTranslationsUseCaseStateControllerTests.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 22.02.2023.
//

import Foundation
import XCTest
import Mockingbird
import LyraPlay

class LoadedPlayMediaWithTranslationsUseCaseStateControllerTests: XCTestCase {
    
    typealias SUT = (
        controller: LoadedPlayMediaWithTranslationsUseCaseStateController,
        delegate: PlayMediaWithTranslationsUseCaseStateControllerDelegateMock,
        activeSession: PlayMediaWithTranslationsUseCaseStateControllerActiveSession
    )
    
    // MARK: - Methods
    
    func createSUT() -> SUT {
        
        let activeSession = PlayMediaWithTranslationsUseCaseStateControllerActiveSession(
            session: .init(
                mediaId: UUID(),
                learningLanguage: "English",
                nativeLanguage: "French"
            ),
            playMediaUseCase: mock(PlayMediaWithSubtitlesUseCase.self),
            provideTranslationsToPlayUseCase: mock(ProvideTranslationsToPlayUseCase.self),
            pronounceTranslationsUseCase: mock(PronounceTranslationsUseCase.self)
        )

        
        let delegate = mock(PlayMediaWithTranslationsUseCaseStateControllerDelegate.self)
        
        let controller = LoadedPlayMediaWithTranslationsUseCaseStateController(
            session: activeSession,
            delegate: delegate
        )
        
        detectMemoryLeak(instance: controller)
        
        return (
            controller,
            delegate,
            activeSession
        )
    }
    
    // MARK: - Methods
    
    func test_play() async throws {
        
        // Given
        
        let sut = createSUT()
        
        given(sut.delegate.play(session: any()))
            .willReturn(.success(()))
        
        // When
        let result = sut.controller.play()
        
        // Then
        try AssertResultSucceded(result)
        
        verify(
            sut.delegate.play(session: any())
        ).wasCalled(1)
    }
    
    func test_stop() async throws {
        
        // Given
        let sut = createSUT()
        
        given(sut.delegate.stop(activeSession: any()))
            .willReturn(.success(()))
        
        // When
        let result = sut.controller.stop()
        
        // Then
        try AssertResultSucceded(result)
        
        verify(sut.delegate.stop(activeSession: any()))
            .wasCalled(1)
    }
    
    func test_prepare() async throws {
        
        // Given
        let sut = createSUT()
        
        let session = anySession()
        
        given(await sut.delegate.load(session: any()))
            .willReturn(.success(()))
        
        // When
        let result = await sut.controller.prepare(session: session)
        
        // Then
        try AssertResultSucceded(result)
        
        verify(await sut.delegate.load(session: session))
            .wasCalled(1)
    }
    
    func anySession() -> PlayMediaWithTranslationsSession {
        
        return .init(
            mediaId: UUID(),
            learningLanguage: "English",
            nativeLanguage: "French"
        )
    }
}
