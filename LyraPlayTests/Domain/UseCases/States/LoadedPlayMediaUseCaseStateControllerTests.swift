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
        initialState: PlayMediaUseCaseStateControllerMock,
        loadingState: PlayMediaUseCaseStateControllerMock,
        playingState: PlayMediaUseCaseStateControllerMock,
        pausedState: PlayMediaUseCaseStateControllerMock,
        audioPlayer: AudioPlayerMock
    )
    
    func createSUT(mediaId: UUID) -> SUT {

        let audioPlayer = mock(AudioPlayer.self)
        
        let loadingState = mock(PlayMediaUseCaseStateController.self)
        let playingState = mock(PlayMediaUseCaseStateController.self)
        let initialState = mock(PlayMediaUseCaseStateController.self)
        let pausedState = mock(PlayMediaUseCaseStateController.self)

        let factories = mock(LoadedPlayMediaUseCaseStateControllerFactories.self)
        
        given(factories.makeInitial(context: any()))
            .willReturn(initialState)
        
        given(factories.makeLoading(mediaId: any(), context: any()))
            .willReturn(loadingState)
        
        given(factories.makePlaying(mediaId: any(), audioPlayer: any(), context: any()))
            .willReturn(playingState)
        
        given(factories.makePaused(mediaId: any(), audioPlayer: any(), context: any()))
            .willReturn(pausedState)
        
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
            initialState,
            loadingState,
            playingState,
            pausedState,
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
    
    func test_play() async throws {

        // Given
        let loadedMediaId = UUID()
        
        let sut = createSUT(mediaId: loadedMediaId)

        // When
        sut.controller.play()

        // Then
        verify(
            sut.factories.makePlaying(
                mediaId: loadedMediaId,
                audioPlayer: sut.audioPlayer,
                context: sut.context
            )
        ).wasCalled(1)
        
        verify(sut.context.set(newState: sut.playingState))
            .wasCalled(1)
    }
    
    func test_stop() async throws {

        // Given
        let loadedMediaId = UUID()
        
        let sut = createSUT(mediaId: loadedMediaId)

        // When
        sut.controller.stop()

        // Then
        verify(
            sut.factories.makeInitial(context: sut.context)
        ).wasCalled(1)
        
        verify(sut.context.set(newState: sut.initialState))
            .wasCalled(1)
    }
    
    func test_pause() async throws {

        // Given
        let loadedMediaId = UUID()
        
        let sut = createSUT(mediaId: loadedMediaId)

        // When
        sut.controller.stop()

        // Then
        verify(
            sut.factories.makePaused(
                mediaId: loadedMediaId,
                audioPlayer: sut.audioPlayer,
                context: sut.context
            )
        ).wasCalled(1)
        
        verify(sut.context.set(newState: sut.pausedState))
            .wasCalled(1)
    }
}
