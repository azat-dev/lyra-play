//
//  PlayingAudioPlayerStateControllerTests.swift
//  LyraPlayTests
//
//  Created by Azat Kaiumov on 06.04.23.
//

import Foundation
import XCTest
import Mockingbird
import LyraPlay
import AVFAudio

class PlayingAudioPlayerStateControllerTests: XCTestCase {
    
    typealias SUT = (
        controller: PlayingAudioPlayerStateController,
        session: ActiveAudioPlayerStateControllerSession,
        delegate: AudioPlayerStateControllerDelegateMock,
        systemPlayer: SystemPlayerMock
    )
    
    func createSUT() -> SUT {
        
        let delegate = mock(AudioPlayerStateControllerDelegate.self)
        
        let fileId = UUID().uuidString
        
        let systemPlayer = mock(SystemPlayer.self)
        
        let session = ActiveAudioPlayerStateControllerSession(
            fileId: fileId,
            systemPlayer: systemPlayer
        )
        
        let controller = PlayingAudioPlayerStateController(
            session: session,
            delegate: delegate
        )
        
        detectMemoryLeak(instance: controller)
        
        releaseMocks(
            delegate,
            systemPlayer
        )
        
        return (
            controller,
            session,
            delegate,
            systemPlayer
        )
    }
    
    func test_prepare() async throws {
        
        // Given
        let sut = createSUT()
        
        let newFileId = "new_file_id"
        let newFileData = "new_file_data".data(using: .utf8)!
        
        given(sut.delegate.load(fileId: any(), data: any()))
            .willReturn(.success(()))
        
        // When
        let result = sut.controller.prepare(
            fileId: newFileId,
            data: newFileData
        )
        
        
        // Then
        try AssertResultSucceded(result)
        
        verify(sut.delegate.load(fileId: newFileId, data: newFileData))
            .wasCalled(1)
    }
    
    func test_stop() async throws {
        
        // Given
        let sut = createSUT()
        let session = sut.session
        
        given(sut.delegate.stop(session: any()))
            .willReturn(.success(()))
        
        // When
        let result = sut.controller.stop()
        
        // Then
        try AssertResultSucceded(result)
        
        verify(
            sut.delegate.stop(
                session: any(
                    ActiveAudioPlayerStateControllerSession.self,
                    where: { $0.fileId == session.fileId }
                )
            )
        ).wasCalled(1)
    }
    
    func test_togglePlay() async throws {
        
        // Given
        let sut = createSUT()
        let session = sut.session
        
        given(sut.delegate.pause(session: any()))
            .willReturn(.success(()))
        
        // When
        let result = sut.controller.toggle()
        
        // Then
        try AssertResultSucceded(result)
        
        verify(
            sut.delegate.pause(
                session: any(
                    ActiveAudioPlayerStateControllerSession.self,
                    where: { $0.fileId == session.fileId }
                )
            )
        ).wasCalled(1)
    }
    
    func test_resume() async throws {
        
        // Given
        let sut = createSUT()
        
        given(sut.delegate.resumePlaying(session: any()))
            .willReturn(.success(()))
        
        // When
        let result = sut.controller.resume()
        
        // Then
        try AssertResultSucceded(result)
        
        verify(sut.delegate.resumePlaying(session: any()))
            .wasNeverCalled()
    }
    
    func test_play() async throws {
        
        // Given
        let sut = createSUT()
        let session = sut.session
        let time: TimeInterval = 30
        
        given(sut.delegate.startPlaying(atTime: any(), session: any()))
            .willReturn(.success(()))
        
        // When
        let result = sut.controller.play(atTime: time)
        
        // Then
        try AssertResultSucceded(result)
        
        verify(
            sut.delegate.startPlaying(
                atTime: time,
                session: any(
                    ActiveAudioPlayerStateControllerSession.self,
                    where: { $0.fileId == session.fileId }
                )
            )
        ).wasCalled(1)
    }
    
    func test_pause() async throws {
        
        // Given
        let sut = createSUT()
        let session = sut.session
        
        given(sut.delegate.pause(session: any()))
            .willReturn(.success(()))
        
        // When
        let result = sut.controller.pause()
        
        // Then
        try AssertResultSucceded(result)
        
        verify(
            sut.delegate.pause(
                session: any(
                    ActiveAudioPlayerStateControllerSession.self,
                    where: { $0.fileId == session.fileId }
                )
            )
        ).wasCalled(1)
    }
    
    func test_runPlaying__with_offset() async throws {
        
        // Given
        let sut = createSUT()
        let systemPlayer = sut.systemPlayer
        
        let time: TimeInterval = 10
        
        given(systemPlayer.play(atTime: any()))
            .willReturn(true)
        
        // When
        let result = sut.controller.runPlaying(atTime: time)
        
        // Then
        try! AssertResultSucceded(result)
        
        verify(systemPlayer.play(atTime: time))
            .wasCalled(1)
        
        verify(
            sut.delegate.didStartPlaying(withController: any())
        ).wasCalled(1)
    }

    func test_runResumePlaying() async throws {
        
        // Given
        let sut = createSUT()
        let systemPlayer = sut.systemPlayer
        
        given(systemPlayer.play())
            .willReturn(true)
        
        // When
        let result = sut.controller.runResumePlaying()
        
        // Then
        try! AssertResultSucceded(result)
        
        verify(systemPlayer.play())
            .wasCalled(1)
        
        verify(
            sut.delegate.didResumePlaying(withController: any())
        ).wasCalled(1)
    }
}
