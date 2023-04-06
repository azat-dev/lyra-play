//
//  StoppedAudioPlayerStateControllerTests.swift
//  LyraPlayTests
//
//  Created by Azat Kaiumov on 06.04.23.
//

import Foundation
import XCTest
import Mockingbird
import LyraPlay
import AVFAudio

class StoppedAudioPlayerStateControllerTests: XCTestCase {
    
    typealias SUT = (
        controller: AudioPlayerStateController,
        session: AudioPlayerSession,
        delegate: AudioPlayerStateControllerDelegateMock
    )
    
    func createSUT() -> SUT {
        
        let delegate = mock(AudioPlayerStateControllerDelegate.self)
        
        let fileId = UUID().uuidString
        
        let session = AudioPlayerSession(fileId: fileId)
        
        let controller = StoppedAudioPlayerStateController(
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
        
        // When
        let result = sut.controller.stop()
        
        // Then
        try AssertResultSucceded(result)
    }
    
    func test_togglePlay() async throws {
        
        // Given
        let sut = createSUT()
        
        // When
        let result = sut.controller.toggle()
        
        // Then
        try AssertResultFailed(result)
    }
    
    func test_resume() async throws {
        
        // Given
        let sut = createSUT()
        
        // When
        let result = sut.controller.resume()
        
        // Then
        try AssertResultFailed(result)
    }
    
    func test_play() async throws {
        
        // Given
        let sut = createSUT()
        let session = sut.session
        
        let time: TimeInterval = 10
        
        // When
        let result = sut.controller.play(atTime: time)
        
        // Then
        try AssertResultFailed(result)
    }
}
