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
        delegate: PlayMediaWithTranslationsUseCaseStateControllerDelegateMock
    )
    
    // MARK: - Methods
    
    func createSUT(session: PlayMediaWithTranslationsUseCaseStateControllerActiveSession) -> SUT {
        
        let delegate = mock(PlayMediaWithTranslationsUseCaseStateControllerDelegate.self)
        
        let controller = LoadedPlayMediaWithTranslationsUseCaseStateControllerImpl(
            session: session,
            delegate: delegate
        )
        
        detectMemoryLeak(instance: controller)
        
        return (
            controller: controller,
            delegate: delegate
        )
    }
    
    // MARK: - Methods
    
    func test_play() async throws {
        
        // Given
        let session = PlayMediaWithTranslationsUseCaseStateControllerActiveSession(
            session: .init(
                mediaId: UUID(),
                learningLanguage: "English",
                nativeLanguage: "French"
            ),
            playMediaUseCase: mock(PlayMediaWithSubtitlesUseCaseNew.self),
            provideTranslationsToPlayUseCase: mock(ProvideTranslationsToPlayUseCase.self),
            pronounceTranslationsUseCase: mock(PronounceTranslationsUseCase.self)
        )
        
        let sut = createSUT(session: session)
        
        given(sut.delegate.play(session: any(), delegate: any()))
            .willReturn(.success(()))
        
        // When
        let result = sut.controller.play()
        
        // Then
        try AssertResultSucceded(result)
        
        verify(
            sut.delegate.play(
                session: any(),
                delegate: any()
            )
        ).wasCalled(1)
    }
}
