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
    
    func createSUT(mediaId: UUID) async -> SUT {

        let audioPlayer = mock(AudioPlayer.self)
        let audioPlayeState = CurrentValueSubject<AudioPlayerState, Never>(.initial)
        
        given(audioPlayer.state)
            .willReturn(audioPlayeState)
        
        given(audioPlayer.play(atTime: any()))
            .willReturn(.success(()))
        
        let delegate = mock(PlayMediaUseCaseStateControllerDelegate.self)
        
        let updatePlayedTimeUseCaseFactory = mock(UpdatePlayedTimeUseCaseFactory.self)
        
        let updatePlayedTimeUseCase = mock(UpdatePlayedTimeUseCase.self)
        
        given(await updatePlayedTimeUseCase.updatePlayedTime(for: any(), time: any()))
            .willReturn(.success(()))
        
        given(updatePlayedTimeUseCaseFactory.make())
            .willReturn(updatePlayedTimeUseCase)
        
        let controller = PlayingPlayMediaUseCaseStateController(
            mediaId: mediaId,
            audioPlayer: audioPlayer,
            delegate: delegate,
            updatePlayedTimeUseCaseFactory: updatePlayedTimeUseCaseFactory
        )
        
        detectMemoryLeak(instance: controller)
        
        releaseMocks(
            delegate,
            audioPlayer,
            updatePlayedTimeUseCase,
            updatePlayedTimeUseCaseFactory
        )
        
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
        
        let sut = await createSUT(mediaId: mediaId)
        
        given(sut.delegate.pause(mediaId: any(), audioPlayer: any()))
            .willReturn(.success(()))
        
        let playerTime: TimeInterval = 1234
        let audioPlayer = sut.audioPlayer
        
        given(audioPlayer.currentTime)
            .willReturn(playerTime)

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
        
        let sut = await createSUT(mediaId: loadedMediaId)
        
        let playerTime: TimeInterval = 1234
        let audioPlayer = sut.audioPlayer
        
        given(audioPlayer.currentTime)
            .willReturn(playerTime)

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
        let sut = await createSUT(mediaId: loadedMediaId)
        
        let playerTime: TimeInterval = 1234
        let audioPlayer = sut.audioPlayer
        
        given(audioPlayer.currentTime)
            .willReturn(playerTime)
        
        given(sut.audioPlayer.play(atTime: 0))
            .willReturn(.success(()))
        
        // When
        let result = sut.controller.runPlaying(atTime: 0)

        // Then
        try AssertResultSucceded(result)
        verify(
            sut.delegate.didStartPlay(withController: any())
        ).wasCalled(1)
        
        verify(sut.audioPlayer.play(atTime: 0))
            .wasCalled(1)
    }
}

