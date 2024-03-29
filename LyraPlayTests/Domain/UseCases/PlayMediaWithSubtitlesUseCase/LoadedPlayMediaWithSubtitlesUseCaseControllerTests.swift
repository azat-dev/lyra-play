//
//  LoadedPlayMediaWithSubtitlesUseCaseControllerTests.swift
//  LyraPlayTests
//
//  Created by Azat Kaiumov on 19.02.23.
//

import Foundation
import XCTest
import Mockingbird

import LyraPlay

class LoadedPlayMediaWithSubtitlesUseCaseControllerTests: XCTestCase {
    
    typealias SUT = (
        controller: LoadedPlayMediaWithSubtitlesUseStateController,
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
            playSubtitlesUseCase: playSubtitlesUseCase,
            subtitlesState: .init(nil)
        )
        
        let controller = LoadedPlayMediaWithSubtitlesUseStateController(
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
    
    func anySubtitles() -> Subtitles {
        
        return .init(duration: 10, sentences: [])
    }
    
    // MARK: - Test Methods
    
    func test_play() async throws {

        // Given
        let mediaId = UUID()
        
        let params = PlayMediaWithSubtitlesSessionParams(
            mediaId: mediaId,
            subtitlesLanguage: "English"
        )
        
        let sut = createSUT(params: params)
        
        given(sut.delegate.play(atTime: 0, session: any()))
            .willReturn(.success(()))
        
        // When
        let result = sut.controller.play(atTime: 0)
        
        // Then
        try AssertResultSucceded(result)
        
        let playSubtitlesUseCase = sut.playSubtitlesUseCase
        let playMediaUseCase = sut.playMediaUseCase
        
        verify(
            sut.delegate.play(
                atTime: 0,
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
