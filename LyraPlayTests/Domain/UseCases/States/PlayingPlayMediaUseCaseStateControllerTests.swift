//
//  PlayingPlayMediaUseCaseStateControllerTests.swift
//  LyraPlayTests
//
//  Created by Azat Kaiumov on 15.02.23.
//

import Foundation
import XCTest
import Mockingbird

import LyraPlay
import Combine

class PlayingPlayMediaUseCaseStateControllerTests: XCTestCase {
    
    typealias SUT = (
        controller: PlayingPlayMediaUseCaseStateController,
        delegate: PlayMediaUseCaseStateControllerDelegateMock,
        audioPlayer: AudioPlayerMock,
        audioPlayerState: CurrentValueSubject<AudioPlayerState, Never>
    )
    
    func createSUT(mediaId: UUID) -> SUT {

        let audioPlayer = mock(AudioPlayer.self)
        let audioPlayeState = CurrentValueSubject<AudioPlayerState, Never>(.initial)
        
        given(audioPlayer.state)
            .willReturn(audioPlayeState)
        
        given(audioPlayer.play())
            .willReturn(.success(()))
        
        let delegate = mock(PlayMediaUseCaseStateControllerDelegate.self)
        
        let controller = PlayingPlayMediaUseCaseStateControllerImpl(
            mediaId: mediaId,
            audioPlayer: audioPlayer,
            delegate: delegate
        )
        
        detectMemoryLeak(instance: controller)
        
        return (
            controller,
            delegate,
            audioPlayer,
            audioPlayeState
        )
    }
    
    // MARK: - Test Methods
    
    func test_pause() async throws {

        // Given
        let mediaId = UUID()
        
        let sut = createSUT(mediaId: mediaId)
        
        given(sut.delegate.pause(mediaId: any(), audioPlayer: any()))
            .willReturn(.success(()))

        // When
        let result = sut.controller.pause()
        try AssertResultSucceded(result)

        // Then
        verify(
            sut.delegate.pause(
                mediaId: mediaId,
                audioPlayer: sut.audioPlayer
            )
        ).wasCalled(1)
    }
    
    func test_finish() async throws {

        // Given
        let loadedMediaId = UUID()
        
        let sut = createSUT(mediaId: loadedMediaId)

        // When
        sut.audioPlayerState.value = .finished(session: .init(fileId: loadedMediaId.uuidString))

        // Then
        verify(
            sut.delegate.didFinish(
                mediaId: loadedMediaId,
                audioPlayer: sut.audioPlayer
            )
        ).wasCalled(1)
    }
    
    func test_run_playing() async throws {

        // Given
        let loadedMediaId = UUID()
        let sut = createSUT(mediaId: loadedMediaId)
        
        given(sut.audioPlayer.play())
            .willReturn(.success(()))
        
        // When
        let result = sut.controller.run()

        // Then
        try AssertResultSucceded(result)
        verify(
            sut.delegate.didStartPlay(
                mediaId: loadedMediaId,
                audioPlayer: sut.audioPlayer
            )
        ).wasCalled(1)
        
        verify(sut.audioPlayer.play())
            .wasCalled(1)
    }
}

