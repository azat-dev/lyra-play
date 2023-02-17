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
        delegate: PlayMediaUseCaseStateControllerDelegateMock,
        audioPlayer: AudioPlayerMock
    )
    
    func createSUT(
        mediaId: UUID,
        loadTrackUseCase: LoadTrackUseCaseMock,
        audioPlayer: AudioPlayerMock
    ) -> SUT {

        let loadTrackUseCaseFactory = mock(LoadTrackUseCaseFactory.self)
        
        given(loadTrackUseCaseFactory.make())
            .willReturn(loadTrackUseCase)
        
        let audioPlayerFactory = mock(AudioPlayerFactory.self)
        
        given(audioPlayerFactory.make())
            .willReturn(audioPlayer)
        
        let delegate = mock(PlayMediaUseCaseStateControllerDelegate.self)
        
        let controller = LoadingPlayMediaUseCaseStateController(
            mediaId: mediaId,
            delegate: delegate,
            loadTrackUseCaseFactory: loadTrackUseCaseFactory,
            audioPlayerFactory: audioPlayerFactory
        )
        
        detectMemoryLeak(instance: controller)
        
        return (
            controller,
            loadTrackUseCase,
            delegate,
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
            sut.delegate.didStartLoading(mediaId: mediaId2)
        ).wasCalled(1)
    }
}

