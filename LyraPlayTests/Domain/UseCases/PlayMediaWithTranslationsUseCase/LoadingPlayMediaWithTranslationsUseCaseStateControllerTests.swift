//
//  LoadingPlayMediaWithTranslationsUseCaseStateControllerTests.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 21.02.2023.
//

import Foundation
import XCTest
import Mockingbird
import Combine
import LyraPlay

class LoadingPlayMediaWithTranslationsUseCaseStateControllerTests: XCTestCase {

    typealias SUT = (
        controller: LoadingPlayMediaWithTranslationsUseCaseStateController,
        delegate: PlayMediaWithTranslationsUseCaseStateControllerDelegateMock,
        playMediaUseCase: PlayMediaWithSubtitlesUseCaseNewMock,
        provideTranslationsToPlayUseCase: ProvideTranslationsToPlayUseCaseMock,
        pronounceTranslationsUseCase: PronounceTranslationsUseCaseMock,
        playMediaUseCaseState: CurrentValueSubject<PlayMediaWithSubtitlesUseCaseStateNew, Never>
    )

    // MARK: - Methods

    func createSUT(session: PlayMediaWithTranslationsSession) -> SUT {

        let delegate = mock(PlayMediaWithTranslationsUseCaseStateControllerDelegate.self)
        
        let playMediaUseCaseState = CurrentValueSubject<PlayMediaWithSubtitlesUseCaseStateNew, Never>(.noActiveSession)
        let playMediaUseCase = mock(PlayMediaWithSubtitlesUseCaseNew.self)
        
        given(playMediaUseCase.state)
            .willReturn(playMediaUseCaseState)

        let playMediaUseCaseFactory = mock(PlayMediaWithSubtitlesUseCaseFactoryNew.self)
        
        given(playMediaUseCaseFactory.make())
            .willReturn(playMediaUseCase)
        
        let provideTranslationsToPlayUseCase = mock(ProvideTranslationsToPlayUseCase.self)
        
        let provideTranslationsToPlayUseCaseFactory = mock(ProvideTranslationsToPlayUseCaseFactory.self)
        
        given(provideTranslationsToPlayUseCaseFactory.make())
            .willReturn(provideTranslationsToPlayUseCase)
        
        let pronounceTranslationsUseCase = mock(PronounceTranslationsUseCase.self)
        
        let pronounceTranslationsUseCaseFactory = mock(PronounceTranslationsUseCaseFactory.self)
        
        given(pronounceTranslationsUseCaseFactory.make())
            .willReturn(pronounceTranslationsUseCase)

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
            pronounceTranslationsUseCase,
            playMediaUseCaseState
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

        given(await sut.playMediaUseCase.prepare(params: any()))
            .willReturn(.success(()))
        
        given(await sut.provideTranslationsToPlayUseCase.prepare(params: any()))
            .willReturn(())
        
        sut.playMediaUseCaseState.value = .activeSession(
            .init(
                mediaId: session.mediaId,
                subtitlesLanguage: session.learningLanguage
            ),
            .loaded(.init(nil), .initial)
        )
        
        // When
        let result = await sut.controller.load(session: session)
        
        // Then
        try AssertResultSucceded(result)
        
        let (_, _, playMediaUseCase, provideTranslationsToPlayUseCase, pronounceTranslationsUseCase, _) = sut

        verify(
            sut.delegate.didLoad(
                session: any(
                    PlayMediaWithTranslationsUseCaseStateControllerActiveSession.self,
                    where: { lhs in
                        return lhs.playMediaUseCase === playMediaUseCase &&
                            lhs.provideTranslationsToPlayUseCase === provideTranslationsToPlayUseCase &&
                            lhs.pronounceTranslationsUseCase === pronounceTranslationsUseCase
                    }
                )
            )
        ).wasCalled(1)
    }
}
