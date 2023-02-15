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
        loadingState: PlayMediaUseCaseStateControllerMock,
        loadedState: PlayMediaUseCaseStateControllerMock,
        failedLoadState: PlayMediaUseCaseStateControllerMock,
        audioPlayer: AudioPlayerMock
    )
    
    func createSUT(
        mediaId: UUID,
        loadTrackUseCase: LoadTrackUseCaseMock,
        audioPlayer: AudioPlayerMock
    ) -> SUT {

        let loadTrackUseCaseFactory = mock(LoadTrackUseCaseFactory.self)
        
        given(loadTrackUseCaseFactory.create()).willReturn(loadTrackUseCase)
        
        let loadingState = mock(PlayMediaUseCaseStateController.self)
        let loadedState = mock(PlayMediaUseCaseStateController.self)
        let failedLoadState = mock(PlayMediaUseCaseStateController.self)

        let factories = mock(LoadingPlayMediaUseCaseStateControllerFactories.self)
        
        let audioPlayerFactory = mock(AudioPlayerFactory.self)
        
        given(audioPlayerFactory.create()).willReturn(audioPlayer)
        
        given(factories.makeLoading(mediaId: any(), context: any()))
            .willReturn(loadingState)
        
        given(factories.makeLoaded(mediaId: any(), audioPlayer: any(), context: any()))
            .willReturn(loadedState)
        
        given(factories.makeFailedLoad(mediaId: any(), context: any()))
            .willReturn(failedLoadState)
        
        let context = mock(PlayMediaUseCaseStateControllerContext.self)
        
        let controller = LoadingPlayMediaUseCaseStateController(
            mediaId: mediaId,
            context: context,
            loadTrackUseCaseFactory: loadTrackUseCaseFactory,
            audioPlayerFactory: audioPlayerFactory,
            statesFactories: factories
        )
        
        detectMemoryLeak(instance: controller)
        
        return (
            controller,
            loadTrackUseCase,
            context,
            factories,
            loadingState,
            loadedState,
            failedLoadState,
            audioPlayer
        )
    }
    
    // MARK: - Test Methods
    
    func test_prepare() async throws {

        // Given
        let mediaId1 = UUID()
        let mediaId2 = UUID()
        
        let loadTrackUseCase = mock(LoadTrackUseCase.self)
        
        given(await loadTrackUseCase.load(trackId: mediaId1))
            .willReturn(.success("success".data(using: .utf8)!))
        
        let audioPlayer = mock(AudioPlayer.self)
        
        given(audioPlayer.prepare(fileId: any(), data: any()))
            .willReturn(.success(()))
        
        let sut = createSUT(
            mediaId: mediaId1,
            loadTrackUseCase: loadTrackUseCase,
            audioPlayer: audioPlayer
        )

        // When
        sut.controller.prepare(mediaId: mediaId2)

        // Then
        verify(
            sut.factories.makeLoading(
                mediaId: mediaId2,
                context: sut.context
            )
        ).wasCalled(1)
        
        verify(sut.context.set(newState: sut.loadingState))
            .wasCalled(1)
    }
}

