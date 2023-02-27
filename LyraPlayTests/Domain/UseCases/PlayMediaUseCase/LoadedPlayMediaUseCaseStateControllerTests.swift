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
        controller: LoadedPlayMediaUseCaseStateController,
        delegate: PlayMediaUseCaseStateControllerDelegateMock,
        audioPlayer: AudioPlayerMock
    )
    
    func createSUT(mediaId: UUID) -> SUT {

        let audioPlayer = mock(AudioPlayer.self)
        
        let delegate = mock(PlayMediaUseCaseStateControllerDelegate.self)
        
        let controller = LoadedPlayMediaUseCaseStateController(
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
        let mediaId = UUID()
        
        let sut = createSUT(mediaId: loadedMediaId)

        given(await sut.delegate.load(mediaId: any()))
            .willReturn(.success(()))

        // When
        let _ = await sut.controller.prepare(mediaId: mediaId)

        // Then
        verify(await sut.delegate.load(mediaId: mediaId))
            .wasCalled(1)
    }
    
    func test_play() async throws {

        // Given
        let loadedMediaId = UUID()
        
        let sut = createSUT(mediaId: loadedMediaId)
        
        given(sut.delegate.play(atTime: 0, mediaId: any(), audioPlayer: any()))
            .willReturn(.success(()))

        // When
        let result = sut.controller.play(atTime: 0)

        // Then
        try AssertResultSucceded(result)
        
        verify(
            sut.delegate.play(
                atTime: 0,
                mediaId: loadedMediaId,
                audioPlayer: sut.audioPlayer
            )
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

        // Then
        try AssertResultSucceded(result)
        verify(sut.delegate.stop(mediaId: loadedMediaId, audioPlayer: any()))
            .wasCalled(1)
    }    
}
