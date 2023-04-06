//
//  InitialAudioPlayerStateControllerTests.swift
//  LyraPlayTests
//
//  Created by Azat Kaiumov on 06.04.23.
//

import Foundation
import XCTest
import Mockingbird
import LyraPlay

class InitialAudioPlayerStateControllerTests: XCTestCase {
    
    typealias SUT = (
        controller: AudioPlayerStateController,
        delegate: AudioPlayerStateControllerDelegateMock
    )
    
    func createSUT() -> SUT {
        
        let delegate = mock(AudioPlayerStateControllerDelegate.self)
        
        let controller = InitialAudioPlayerStateController(
            delegate: delegate
        )
        
        detectMemoryLeak(instance: controller)
        
        releaseMocks(
            delegate
        )
        
        return (
            controller,
            delegate
        )
    }
    
    
    func test_prepare() async throws {
        
        // Given
        let sut = createSUT()

        let fileId = UUID().uuidString
        let fileData = "some".data(using: .utf8)!
        
        given(sut.delegate.load(fileId: any(), data: any()))
            .willReturn(.success(()))
        
        
        // When
        let result = sut.controller.prepare(
            fileId: fileId,
            data: fileData
        )
        
        try AssertResultSucceded(result)
        
        // Then
        
        verify(sut.delegate.load(fileId: fileId, data: fileData))
            .wasCalled(1)
        
    }
}
