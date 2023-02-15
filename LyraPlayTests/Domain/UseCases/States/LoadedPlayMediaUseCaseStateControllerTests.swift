//
//  LoadedPlayMediaUseCaseStateControllerTests.swift
//  LyraPlayTests
//
//  Created by Azat Kaiumov on 15.02.23.
//

import Foundation
import XCTest
import Mockingbird

import LyraPlay

class LoadedPlayMediaUseCaseStateControllerTests: XCTestCase {
    
    typealias SUT = (
        controller: PlayMediaUseCaseStateController,
        context: PlayMediaUseCaseStateControllerContextMock,
        factories: LoadedPlayMediaUseCaseStateControllerFactoriesMock,
        loadingState: PlayMediaUseCaseStateControllerMock,
        audioPlayer: AudioPlayerMock
    )
    
    func createSUT(mediaId: UUID) -> SUT {

        let audioPlayer = mock(AudioPlayer.self)
        
        let loadingState = mock(PlayMediaUseCaseStateController.self)
        let loadedState = mock(PlayMediaUseCaseStateController.self)
        let failedLoadState = mock(PlayMediaUseCaseStateController.self)

        let factories = mock(LoadedPlayMediaUseCaseStateControllerFactories.self)
        
        given(factories.makeLoading(mediaId: any(), context: any()))
            .willReturn(loadingState)
        
        let context = mock(PlayMediaUseCaseStateControllerContext.self)
        
        let controller = LoadedPlayMediaUseCaseStateController(
            mediaId: mediaId,
            audioPlayer: audioPlayer,
            context: context,
            statesFactories: factories
        )
        
        detectMemoryLeak(instance: controller)
        
        return (
            controller,
            context,
            factories,
            loadingState,
            audioPlayer
        )
    }
    
    // MARK: - Test Methods
    
    func test_prepare() async throws {

        // Given
        let loadedMediaId = UUID()
        let preparingMediaId = UUID()
        
        let sut = createSUT(mediaId: loadedMediaId)

        // When
        sut.controller.prepare(mediaId: preparingMediaId)

        // Then
        verify(
            sut.factories.makeLoading(
                mediaId: preparingMediaId,
                context: sut.context
            )
        ).wasCalled(1)
        
        verify(sut.context.set(newState: sut.loadingState))
            .wasCalled(1)
    }
}
