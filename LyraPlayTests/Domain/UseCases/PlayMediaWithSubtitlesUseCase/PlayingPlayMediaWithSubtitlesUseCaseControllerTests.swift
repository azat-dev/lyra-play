//
//  PlayingPlayMediaWithSubtitlesUseCaseControllerTests.swift
//  LyraPlayTests
//
//  Created by Azat Kaiumov on 19.02.23.
//

import Foundation
import XCTest
import Mockingbird

import LyraPlay

class PlayingPlayMediaWithSubtitlesUseCaseControllerTests: XCTestCase {
    
    typealias SUT = (
        controller: PlayingPlayMediaWithSubtitlesUseStateController,
        delegate: PlayMediaWithSubtitlesUseStateControllerDelegateMock,
        playMediaUseCase: PlayMediaUseCaseMock,
        playSubtitlesUseCase: PlaySubtitlesUseCaseMock
    )
    
    func createSUT(params: PlayMediaWithSubtitlesSessionParams) -> SUT {
        
        let delegate = mock(PlayMediaWithSubtitlesUseStateControllerDelegate.self)
        
        let playMediaUseCase = mock(PlayMediaUseCase.self)
        let playSubtitlesUseCase = mock(PlaySubtitlesUseCase.self)
        
        let session = PlayMediaWithSubtitlesUseStateControllerActiveSession(
            params: params,
            playMediaUseCase: playMediaUseCase,
            playSubtitlesUseCase: playSubtitlesUseCase
        )
        
        let controller = PlayingPlayMediaWithSubtitlesUseStateControllerImpl(
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
            playSubtitlesUseCase
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
        
        verify(
            sut.delegate.didStartPlay(
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
}
