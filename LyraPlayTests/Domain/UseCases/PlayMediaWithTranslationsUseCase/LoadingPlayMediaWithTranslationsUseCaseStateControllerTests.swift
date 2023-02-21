//
//  LoadingPlayMediaWithTranslationsUseCaseStateControllerTests.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 21.02.2023.
//

import Foundation
import XCTest
import Mockingbird
import LyraPlay

class LoadingPlayMediaWithTranslationsUseCaseStateControllerTests: XCTestCase {

    typealias SUT = (
        controller: LoadingPlayMediaWithTranslationsUseCaseStateController,
        delegate: PlayMediaWithTranslationsUseCaseStateControllerDelegateMock,
        playMediaUseCase: PlayMediaWithSubtitlesUseCaseNewMock,
        provideTranslationsToPlayUseCase: ProvideTranslationsToPlayUseCaseMock,
        pronounceTranslationsUseCase: PronounceTranslationsUseCaseMock
    )

    // MARK: - Methods

    func createSUT(session: PlayMediaWithTranslationsSession) -> SUT {

        let delegate = mock(PlayMediaWithTranslationsUseCaseStateControllerDelegate.self)
        
        let playMediaUseCase = mock(PlayMediaWithSubtitlesUseCaseNew.self)

        let playMediaUseCaseFactory = mock(PlayMediaWithSubtitlesUseCaseFactoryNew.self)
        
        given(playMediaUseCaseFactory.make())
            .willReturn(playMediaUseCase)
        
        let provideTranslationsToPlayUseCase = mock(ProvideTranslationsToPlayUseCase.self)
        
        let provideTranslationsToPlayUseCaseFactory = mock(ProvideTranslationsToPlayUseCaseFactory.self)
        
        given(provideTranslationsToPlayUseCaseFactory.make())
            .willReturn(provideTranslationsToPlayUseCase)
        
        let pronounceTranslationsUseCase = mock(PronounceTranslationsUseCase.self)
        
        let pronounceTranslationsUseCaseFactory = mock(PronounceTranslationsUseCaseFactory.self)
        
        given(provideTranslationsToPlayUseCaseFactory.make())
            .willReturn(provideTranslationsToPlayUseCase)

        let controller = LoadingPlayMediaWithTranslationsUseCaseStateControllerImpl(
            session: session,
            delegate: delegate,
            playMediaUseCaseFactory: playMediaUseCaseFactory,
            provideTranslationsToPlayUseCaseFactory: provideTranslationsToPlayUseCaseFactory,
            pronounceTranslationsUseCaseFactory: pronounceTranslationsUseCaseFactory
        )

        detectMemoryLeak(instance: controller)

        return (
            controller,
            delegate,
            playMediaUseCase,
            provideTranslationsToPlayUseCase,
            pronounceTranslationsUseCase
        )
    }
    
    // MARK: - Methods
    
    func test_load() async throws {
        
        // Given
        let session = PlayMediaWithTranslationsSession(
            mediaId: UUID(),
            learningLanguage: "English",
            nativeLanguage: "French"
        )
        
        let sut = createSUT(session: session)

        given(await sut.delegate.load(session: any()))
            .willReturn(.success(()))
        
        // When
        let result = await sut.controller.load(session: session)
        
        // Then
        try AssertResultSucceded(result)
        
        let (_, _, playMediaUseCase, provideTranslationsToPlayUseCase, pronounceTranslationsUseCase) = sut

        verify(
            sut.delegate.didLoad(
                session: any(
                    PlayMediaWithTranslationsUseCaseStateControllerActiveSession.self,
                    where: { [weak self] lhs in
                        return lhs.playMediaUseCase === playMediaUseCase &&
                            lhs.provideTranslationsToPlayUseCase === provideTranslationsToPlayUseCase &&
                            lhs.pronounceTranslationsUseCase === pronounceTranslationsUseCase
                    }
                )
            )
        ).wasCalled(1)
    }
}
