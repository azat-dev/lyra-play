//
//  LoadingPlayMediaUseCaseStateControllerTests.swift
//  LyraPlayTests
//
//  Created by Azat Kaiumov on 14.02.23.
//

import Foundation
import XCTest
import Mockingbird

import LyraPlay

class LoadingPlayMediaUseCaseStateControllerTests: XCTestCase {
    
    typealias SUT = (
        controller: PlayMediaUseCaseStateController,
        loadTrackUseCase: LoadTrackUseCaseMock,
        context: PlayMediaUseCaseStateControllerContextMock,
        factories: LoadingPlayMediaUseCaseStateControllerFactoriesMock,
        loadingState: PlayMediaUseCaseStateController,
        audioPlayer: AudioPlayerMock
    )
    
    func createSUT(mediaId: UUID) -> SUT {

        let audioPlayer = mock(AudioPlayer.self)
        
        let loadTrackUseCase = mock(LoadTrackUseCase.self)
        
        let loadingState = mock(PlayMediaUseCaseStateController.self)

        let factories = mock(LoadingPlayMediaUseCaseStateControllerFactories.self)
        
        given(factories.makeLoading(mediaId: any(), context: any()))
            .willReturn(loadingState)
        
        let context = mock(PlayMediaUseCaseStateControllerContext.self)
        
        let controller = LoadingPlayMediaUseCaseStateController(
            mediaId: mediaId,
            context: context,
            loadTrackUseCase: loadTrackUseCase,
            statesFactories: factories
        )
        
        detectMemoryLeak(instance: controller)
        
        return (
            controller,
            loadTrackUseCase,
            context,
            factories,
            loadingState,
            audioPlayer
        )
    }
    
    // MARK: - Test Methods
    
    func test_loading__success() async throws {

        // Given
        let mediaId = UUID()
        let sut = createSUT(mediaId: mediaId)
        
        given(await sut.loadTrackUseCase.load(trackId: mediaId))
            .willReturn(.failure(.internalError(nil)))
        
        // When
        // Creation
        
        // Then
        verify(await sut.loadTrackUseCase.load(trackId: mediaId))
            .wasCalled(1)
        
        verify(
            sut.factories.makeLoaded(
                mediaId: mediaId,
                audioPlayer: sut.audioPlayer,
                context: sut.context
            )
        ).wasCalled(1)
    }
}

