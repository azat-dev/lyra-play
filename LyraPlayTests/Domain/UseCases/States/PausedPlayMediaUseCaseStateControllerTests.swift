//
//  PausedPlayMediaUseCaseStateControllerTests.swift
//  LyraPlayTests
//
//  Created by Azat Kaiumov on 15.02.23.
//

import Foundation
import XCTest
import Mockingbird

import LyraPlay

class PausedPlayMediaUseCaseStateControllerTests: XCTestCase {
    
    typealias SUT = (
        controller: PlayMediaUseCaseStateController,
        delegate: PlayMediaUseCaseStateControllerDelegateMock,
        audioPlayer: AudioPlayerMock
    )
    
    func createSUT(mediaId: UUID) -> SUT {

        let audioPlayer = mock(AudioPlayer.self)
        
        given(audioPlayer.pause())
            .willReturn(.success(()))
        
        let delegate = mock(PlayMediaUseCaseStateControllerDelegate.self)
        
        let controller = PausedPlayMediaUseCaseStateController(
            mediaId: mediaId,
            audioPlayer: audioPlayer,
            delegate: delegate
        )
        
        detectMemoryLeak(instance: controller)
        
        return (
            controller,
            delegate,
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
        
        verify(
            sut.delegate.didStop()
        ).wasCalled(1)
    }
    
    func test_play() async throws {

        // Given
        let loadedMediaId = UUID()
        
        let sut = createSUT(mediaId: loadedMediaId)

        // When
        sut.controller.play()

        // Then
        verify(
            sut.delegate.didStartPlaying(
                mediaId: loadedMediaId,
                audioPlayer: sut.audioPlayer
            )
        ).wasCalled(1)
    }
}

