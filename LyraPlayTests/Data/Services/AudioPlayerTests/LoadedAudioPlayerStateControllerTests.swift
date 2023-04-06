//
//  LoadedAudioPlayerStateControllerTests.swift
//  LyraPlayTests
//
//  Created by Azat Kaiumov on 06.04.23.
//

import Foundation
import XCTest
import Mockingbird
import LyraPlay
import AVFAudio

class LoadedAudioPlayerStateControllerTests: XCTestCase {
    
    typealias SUT = (
        controller: AudioPlayerStateController,
        session: ActiveAudioPlayerStateControllerSession,
        delegate: AudioPlayerStateControllerDelegateMock
    )
    
    func createSUT() -> SUT {
        
        let delegate = mock(AudioPlayerStateControllerDelegate.self)
        
        let fileId = UUID().uuidString
        
        let session = ActiveAudioPlayerStateControllerSession(
            fileId: fileId,
            systemPlayer: AVAudioPlayer()
        )
        
        let controller = LoadedAudioPlayerStateController(
            session: session,
            delegate: delegate
        )
        
        detectMemoryLeak(instance: controller)
        
        releaseMocks(
            delegate
        )
        
        return (
            controller,
            session,
            delegate
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
        
        try AssertResultSucceded(result)
        
        // Then
        
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
        
        try AssertResultSucceded(result)
        
        // Then
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
        
        given(sut.delegate.startPlaying(atTime: any(), session: any()))
            .willReturn(.success(()))
        
        // When
        let result = sut.controller.toggle()
        
        try AssertResultSucceded(result)
        
        // Then
        verify(
            sut.delegate.startPlaying(
                atTime: 0,
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
        let session = sut.session
        
        given(sut.delegate.resumePlaying(session: any()))
            .willReturn(.success(()))
        
        // When
        let result = sut.controller.resume()
        
        try AssertResultSucceded(result)
        
        // Then
        verify(
            sut.delegate.resumePlaying(
                session: any(
                    ActiveAudioPlayerStateControllerSession.self,
                    where: { $0.fileId == session.fileId }
                )
            )
        ).wasCalled(1)
    }
    
    func test_play() async throws {
        
        // Given
        let sut = createSUT()
        let session = sut.session
        
        let time: TimeInterval = 10
        
        given(sut.delegate.startPlaying(atTime: any(), session: any()))
            .willReturn(.success(()))
        
        // When
        let result = sut.controller.play(atTime: time)
        
        try AssertResultSucceded(result)
        
        // Then
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
}
