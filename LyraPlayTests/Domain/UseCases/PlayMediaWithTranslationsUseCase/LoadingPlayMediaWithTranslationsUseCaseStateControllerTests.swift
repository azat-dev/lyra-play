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
        playMediaUseCase: PlayMediaWithSubtitlesUseCaseMock,
        provideTranslationsToPlayUseCase: ProvideTranslationsToPlayUseCaseMock,
        pronounceTranslationsUseCase: PronounceTranslationsUseCaseMock,
        playMediaUseCaseState: CurrentValueSubject<PlayMediaWithSubtitlesUseCaseState, Never>,
        subtitlesState: CurrentValueSubject<SubtitlesState?, Never>
    )

    // MARK: - Methods

    func createSUT(session: PlayMediaWithTranslationsSession) -> SUT {

        let delegate = mock(PlayMediaWithTranslationsUseCaseStateControllerDelegate.self)
        
        let playMediaUseCaseState = CurrentValueSubject<PlayMediaWithSubtitlesUseCaseState, Never>(.noActiveSession)
        let subtitlesState = CurrentValueSubject<SubtitlesState?, Never>(nil)
        let playMediaUseCase = mock(PlayMediaWithSubtitlesUseCase.self)
        
        given(playMediaUseCase.state)
            .willReturn(playMediaUseCaseState)
        
        given(playMediaUseCase.subtitlesState)
            .willReturn(subtitlesState)

        let playMediaUseCaseFactory = mock(PlayMediaWithSubtitlesUseCaseFactory.self)
        
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

        let controller = LoadingPlayMediaWithTranslationsUseCaseStateController(
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
            playMediaUseCaseState,
            subtitlesState
        )
    }
    
    // MARK: - Methods
    
    func test_load() async throws {
        
        // Given
        let session = anySession()
        
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
            .init(.loaded)
        )
        
        sut.subtitlesState.value = .init(timeSlot: nil, subtitles: anySubtitles(), timeSlots: [])
        
        // When
        let result = await sut.controller.load()
        
        // Then
        try AssertResultSucceded(result)
        
        let (_, _, playMediaUseCase, provideTranslationsToPlayUseCase, pronounceTranslationsUseCase, _, _) = sut

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
    
    func test_stop() async throws {
        
        // Given
        let session = anySession()
        let sut = createSUT(session: session)
        
        given(sut.delegate.stop(session: session))
            .willReturn(.success(()))
        
        // When
        let result = sut.controller.stop()
        
        // Then
        try AssertResultSucceded(result)
        
        verify(sut.delegate.stop(session: session))
            .wasCalled(1)
    }
    
    // MARK: - Helpers
    
    func anySession() -> PlayMediaWithTranslationsSession {
        
        return .init(
            mediaId: UUID(),
            learningLanguage: "English",
            nativeLanguage: "French"
        )
    }
    
    private func anySubtitles() -> Subtitles {
        
        return .init(duration: 0, sentences: [])
    }
}
