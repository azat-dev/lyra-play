//
//  LoadingPlayMediaWithSubtitlesUseCaseControllerTests.swift
//  LyraPlayTests
//
//  Created by Azat Kaiumov on 19.02.23.
//

import Foundation
import XCTest
import Mockingbird

import LyraPlay

class LoadingPlayMediaWithSubtitlesUseCaseControllerTests: XCTestCase {
    
    typealias SUT = (
        controller: LoadingPlayMediaWithSubtitlesUseStateControllerDeprecated,
        delegate: PlayMediaWithSubtitlesUseStateControllerDelegateMock,
        playMediaUseCaseFactory: PlayMediaUseCaseFactoryMock,
        playMediaUseCase: PlayMediaUseCaseMock,
        loadSubtitlesUseCaseFactory: LoadSubtitlesUseCaseFactoryMock,
        loadSubtitlesUseCase: LoadSubtitlesUseCaseMock,
        playSubtitlesUseCaseFactory: PlaySubtitlesUseCaseFactoryMock,
        playSubtitlesUseCase: PlaySubtitlesUseCaseMock
    )
    
    func createSUT(params: PlayMediaWithSubtitlesSessionParams) -> SUT {
        
        let delegate = mock(PlayMediaWithSubtitlesUseStateControllerDelegate.self)
        
        let playMediaUseCase = mock(PlayMediaUseCase.self)
        
        let playMediaUseCaseFactory = mock(PlayMediaUseCaseFactory.self)
        
        given(playMediaUseCaseFactory.make())
            .willReturn(playMediaUseCase)
        
        let loadSubtitlesUseCaseFactory = mock(LoadSubtitlesUseCaseFactory.self)
        
        let loadSubtitlesUseCase = mock(LoadSubtitlesUseCase.self)
        
        given(loadSubtitlesUseCaseFactory.make())
            .willReturn(loadSubtitlesUseCase)
        
        let playSubtitlesUseCaseFactory = mock(PlaySubtitlesUseCaseFactory.self)
        
        let playSubtitlesUseCase = mock(PlaySubtitlesUseCase.self)
        
        given(playSubtitlesUseCaseFactory.make(subtitles: any()))
            .willReturn(playSubtitlesUseCase)
        
        let controller = LoadingPlayMediaWithSubtitlesUseStateController(
            params: params,
            delegate: delegate,
            playMediaUseCaseFactory: playMediaUseCaseFactory,
            loadSubtitlesUseCaseFactory: loadSubtitlesUseCaseFactory,
            playSubtitlesUseCaseFactory: playSubtitlesUseCaseFactory
        )
        
        detectMemoryLeak(instance: controller)
        
        releaseMocks(
            delegate,
            playMediaUseCaseFactory,
            playMediaUseCase,
            loadSubtitlesUseCaseFactory,
            loadSubtitlesUseCase,
            playSubtitlesUseCaseFactory,
            playSubtitlesUseCase
        )
        
        return (
            controller,
            delegate,
            playMediaUseCaseFactory,
            playMediaUseCase,
            loadSubtitlesUseCaseFactory,
            loadSubtitlesUseCase,
            playSubtitlesUseCaseFactory,
            playSubtitlesUseCase
        )
    }
    
    func anySubtitles() -> Subtitles {
        
        return .init(duration: 10, sentences: [])
    }
    
    // MARK: - Test Methods
    
    func test_load() async throws {

        // Given
        let mediaId = UUID()
        
        let params = PlayMediaWithSubtitlesSessionParams(
            mediaId: mediaId,
            subtitlesLanguage: "English"
        )
        
        let sut = createSUT(params: params)
        
        let subtitles = anySubtitles()
        
        given(await sut.loadSubtitlesUseCase.load(for: any(), language: any()))
            .willReturn(.success(subtitles))
        
        given(await sut.playMediaUseCase.prepare(mediaId: any()))
            .willReturn(.success(()))
        
        given(sut.playSubtitlesUseCaseFactory.make(subtitles: any()))
            .willReturn(sut.playSubtitlesUseCase)
        
        // When
        let result = await sut.controller.load()
        
        // Then
        try AssertResultSucceded(result)
        
        verify(await sut.loadSubtitlesUseCase.load(for: mediaId, language: params.subtitlesLanguage))
            .wasCalled(1)
        
        verify(await sut.playMediaUseCase.prepare(mediaId: mediaId))
            .wasCalled(1)
        
        verify(sut.playSubtitlesUseCaseFactory.make(subtitles: subtitles))
            .wasCalled(1)
        
        let expectedSession = PlayMediaWithSubtitlesUseStateControllerActiveSession(
            params: params,
            playMediaUseCase: sut.playMediaUseCase,
            playSubtitlesUseCase: sut.playSubtitlesUseCase,
            subtitlesState: .init(nil)
        )
        
        let playSubtitlesUseCase = sut.playSubtitlesUseCase
        let playMediaUseCase = sut.playMediaUseCase
        
        verify(
            sut.delegate.didLoad(
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
