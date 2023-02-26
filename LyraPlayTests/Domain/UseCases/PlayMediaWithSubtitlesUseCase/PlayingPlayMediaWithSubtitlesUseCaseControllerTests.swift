//
//  PlayingPlayMediaWithSubtitlesUseCaseControllerTests.swift
//  LyraPlayTests
//
//  Created by Azat Kaiumov on 19.02.23.
//

import Foundation
import Combine
import XCTest
import Mockingbird

import LyraPlay

class PlayingPlayMediaWithSubtitlesUseCaseControllerTests: XCTestCase {
    
    typealias SUT = (
        controller: PlayingPlayMediaWithSubtitlesUseStateController,
        delegate: PlayMediaWithSubtitlesUseStateControllerDelegateMock,
        playMediaUseCase: PlayMediaUseCaseMock,
        playSubtitlesUseCase: PlaySubtitlesUseCaseMock,
        playSubtitlesState: CurrentValueSubject<PlaySubtitlesUseCaseState, Never>,
        playMediaState: CurrentValueSubject<PlayMediaUseCaseState, Never>
    )
    
    func createSUT(params: PlayMediaWithSubtitlesSessionParams) -> SUT {
        
        let delegate = mock(PlayMediaWithSubtitlesUseStateControllerDelegate.self)
        
        let playMediaUseCase = mock(PlayMediaUseCase.self)
        let playSubtitlesUseCase = mock(PlaySubtitlesUseCase.self)
        
        let playSubtitlesState = CurrentValueSubject<PlaySubtitlesUseCaseState, Never>(.initial)
        
        given(playSubtitlesUseCase.state)
            .willReturn(playSubtitlesState)
        
        let playMediaState = CurrentValueSubject<PlayMediaUseCaseState, Never>(.playing(mediaId: params.mediaId))
        
        given(playMediaUseCase.state)
            .willReturn(playMediaState)
        
        let session = PlayMediaWithSubtitlesUseStateControllerActiveSession(
            params: params,
            playMediaUseCase: playMediaUseCase,
            playSubtitlesUseCase: playSubtitlesUseCase,
            subtitlesState: .init(nil)
        )
        
        let controller = PlayingPlayMediaWithSubtitlesUseStateController(
            session: session,
            delegate: delegate
        )
        
        detectMemoryLeak(instance: controller)
        
        releaseMocks(
            delegate,
            playMediaUseCase,
            playSubtitlesUseCase
        )
        
        return (
            controller,
            delegate,
            playMediaUseCase,
            playSubtitlesUseCase,
            playSubtitlesState,
            playMediaState
        )
    }
    
    // MARK: - Test Methods
    
    func test_run() async throws {

        // Given
        let mediaId = UUID()
        
        let params = PlayMediaWithSubtitlesSessionParams(
            mediaId: mediaId,
            subtitlesLanguage: "English"
        )
        
        let sut = createSUT(params: params)
        
        given(sut.playMediaUseCase.play())
            .willReturn(.success(()))
        
        given(sut.playSubtitlesUseCase.play())
            .willReturn(())
        
        // When
        let result = sut.controller.run()
        
        // Then
        try AssertResultSucceded(result)
        
        let playSubtitlesUseCase = sut.playSubtitlesUseCase
        let playMediaUseCase = sut.playMediaUseCase
        
        verify(playMediaUseCase.play())
            .wasCalled(1)
        
        verify(playSubtitlesUseCase.play())
            .wasCalled(1)
        
        verify(
            sut.delegate.didStartPlay(
                controller: any()
            )
        ).wasCalled(1)
    }
    
    func test_pause() async throws {

        // Given
        let mediaId = UUID()
        
        let params = PlayMediaWithSubtitlesSessionParams(
            mediaId: mediaId,
            subtitlesLanguage: "English"
        )
        
        let sut = createSUT(params: params)
        
        given(sut.delegate.pause(session: any()))
            .willReturn(.success(()))
        
        // When
        let result = sut.controller.pause()
        
        // Then
        try AssertResultSucceded(result)
        
        let playSubtitlesUseCase = sut.playSubtitlesUseCase
        let playMediaUseCase = sut.playMediaUseCase
        
        verify(
            sut.delegate.pause(
                session: any(
                    PlayMediaWithSubtitlesUseStateControllerActiveSession.self,
                    where: { [weak playSubtitlesUseCase, weak playMediaUseCase] lhs in
                        lhs.params == params &&
                        lhs.playSubtitlesUseCase === playSubtitlesUseCase &&
                        lhs.playMediaUseCase === playMediaUseCase
                    }
                )
            )
        ).wasCalled(1)
    }
    
    func test_finish__subtitles_finished_first() async throws {

        // Given
        let mediaId = UUID()
        
        let params = PlayMediaWithSubtitlesSessionParams(
            mediaId: mediaId,
            subtitlesLanguage: "English"
        )
        
        let sut = createSUT(params: params)
        
        given(sut.delegate.pause(session: any()))
            .willReturn(.success(()))
        
        // When
        sut.playSubtitlesState.value = .finished
        
        // Then
        verify(sut.delegate.didFinish(session: any()))
            .wasNeverCalled()        
    }
    
    func test_finish__media_finished_first() async throws {

        // Given
        let mediaId = UUID()
        
        let params = PlayMediaWithSubtitlesSessionParams(
            mediaId: mediaId,
            subtitlesLanguage: "English"
        )
        
        let sut = createSUT(params: params)
       
        given(sut.playMediaUseCase.play())
            .willReturn(.success(()))
        
        given(sut.delegate.pause(session: any()))
            .willReturn(.success(()))
        
        given(sut.playSubtitlesUseCase.pause())
            .willReturn(())
        
        // When
        let _ = sut.controller.run()
        sut.playMediaState.value = .finished(mediaId: mediaId)
        
        // Then
        
        eventually {
            verify(sut.delegate.didFinish(session: any()))
                .wasCalled(1)
            
            verify(sut.playSubtitlesUseCase.pause())
                .wasCalled(1)
        }
        
        await waitForExpectations(timeout: 1)
    }
}
