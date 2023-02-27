//
//  PausedPlayMediaUseCaseStateControllerTests.swift
//  LyraPlayTests
//
//  Created by Azat Kaiumov on 15.02.23.
//

import Foundation
import XCTest
import Combine
import Mockingbird

import LyraPlay

class PausedPlayMediaUseCaseStateControllerTests: XCTestCase {
    
    typealias SUT = (
        controller: PlayMediaUseCaseStateController,
        delegate: PlayMediaUseCaseStateControllerDelegateMock,
        audioPlayer: AudioPlayerMock,
        audioPlayerState: CurrentValueSubject<AudioPlayerState, Never>
    )
    
    func createSUT(mediaId: UUID) -> SUT {

        let audioPlayer = mock(AudioPlayer.self)
        
        given(audioPlayer.pause())
            .willReturn(.success(()))
        
        let audioPlayerState = CurrentValueSubject<AudioPlayerState, Never>(.initial)
        
        given(audioPlayer.state)
            .willReturn(audioPlayerState)
        
        let delegate = mock(PlayMediaUseCaseStateControllerDelegate.self)
        
        let controller = PausedPlayMediaUseCaseStateControllerImpl(
            mediaId: mediaId,
            audioPlayer: audioPlayer,
            delegate: delegate
        )
        
        detectMemoryLeak(instance: controller)
        
        return (
            controller,
            delegate,
            audioPlayer,
            audioPlayerState
        )
    }
    
    // MARK: - Test Methods
    
    func test_prepare() async throws {

        // Given
        let loadedMediaId = UUID()
        let preparingMediaId = UUID()

        let sut = createSUT(mediaId: loadedMediaId)
        
        given(await sut.delegate.load(mediaId: any()))
            .willReturn(.success(()))

        // When
        let result = await sut.controller.prepare(mediaId: preparingMediaId)
        try AssertResultSucceded(result)

        // Then
        verify(
            await sut.delegate.load(mediaId: preparingMediaId)
        ).wasCalled(1)
    }
    
    func test_stop() async throws {

        // Given
        let loadedMediaId = UUID()
        
        let sut = createSUT(mediaId: loadedMediaId)
        
        given(sut.delegate.stop(mediaId: any(), audioPlayer: any()))
            .willReturn(.success(()))

        // When
        let result = sut.controller.stop()
        try AssertResultSucceded(result)

        // Then
        verify(sut.delegate.stop(mediaId: loadedMediaId, audioPlayer: sut.audioPlayer))
            .wasCalled(1)
    }
    
    func test_play() async throws {

        // Given
        let loadedMediaId = UUID()
        
        let sut = createSUT(mediaId: loadedMediaId)
        
        given(sut.delegate.play(mediaId: any(), audioPlayer: any()))
            .willReturn(.success(()))

        // When
        let result = sut.controller.play()
        try AssertResultSucceded(result)

        // Then
        verify(
            sut.delegate.play(
                mediaId: loadedMediaId,
                audioPlayer: sut.audioPlayer
            )
        ).wasCalled(1)
    }
}

