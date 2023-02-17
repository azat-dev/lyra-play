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
        controller: PlayMediaUseCaseStateController,
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
        
        let controller = PlayingPlayMediaUseCaseStateController(
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
    
    func test_prepare() async throws {

        // Given
        let loadedMediaId = UUID()
        let preparingMediaId = UUID()

        let sut = createSUT(mediaId: loadedMediaId)

        // When
        sut.controller.prepare(mediaId: preparingMediaId)

        // Then
        verify(
            sut.delegate.didStartLoading(mediaId: preparingMediaId)
        ).wasCalled(1)
    }
    
    func test_stop() async throws {

        // Given
        let loadedMediaId = UUID()
        
        let sut = createSUT(mediaId: loadedMediaId)
        
        given(sut.audioPlayer.stop())
            .willReturn(.success(()))

        // When
        sut.controller.stop()

        // Then
        verify(sut.audioPlayer.stop())
            .wasCalled(1)
        
        verify(sut.delegate.didStop())
            .wasCalled(1)
    }
    
    func test_pause() async throws {

        // Given
        let loadedMediaId = UUID()
        
        let sut = createSUT(mediaId: loadedMediaId)

        // When
        sut.controller.pause()

        // Then
        verify(
            sut.delegate.didPause(
                mediaId: loadedMediaId,
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
}

