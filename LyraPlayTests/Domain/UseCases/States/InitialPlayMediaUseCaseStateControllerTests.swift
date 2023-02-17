//
//  InitialPlayMediaUseCaseStateControllerTests.swift
//  LyraPlayTests
//
//  Created by Azat Kaiumov on 14.02.23.
//

import Foundation
import XCTest
import Mockingbird

import LyraPlay

class InitialPlayMediaUseCaseStateControllerTests: XCTestCase {
    
    typealias SUT = (
        controller: PlayMediaUseCaseStateController,
        delegate: PlayMediaUseCaseStateControllerDelegateMock
    )
    
    func createSUT() -> SUT {
        
        let delegate = mock(PlayMediaUseCaseStateControllerDelegate.self)
        let controller = InitialPlayMediaUseCaseStateController(delegate: delegate)
        
        detectMemoryLeak(instance: controller)
        
        return (
            controller,
            delegate
        )
    }
    
    // MARK: - Test Methods
    
    func test_preparing() async throws {
        
        let sut = createSUT()

        // Given
        let mediaId = UUID()
        
        // When
        sut.controller.prepare(mediaId: mediaId)
        
        // Then
        verify(sut.delegate.didStartLoading(mediaId: mediaId))
            .wasCalled(1)
    }
}
