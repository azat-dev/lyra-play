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
        context: PlayMediaUseCaseStateControllerContext,
        factories: InitialPlayMediaUseCaseStateControllerFactories,
        loadingState: PlayMediaUseCaseStateController
    )
    
    func createSUT() -> SUT {
        
        let loadingState = mock(PlayMediaUseCaseStateController.self)

        let factories = mock(InitialPlayMediaUseCaseStateControllerFactories.self)
        
        given(factories.makeLoading(mediaId: any(), context: any()))
            .willReturn(loadingState)
        
        let context = mock(PlayMediaUseCaseStateControllerContext.self)
        
        let controller = InitialPlayMediaUseCaseStateController(
            context: context,
            statesFactories: factories
        )
        
        detectMemoryLeak(instance: controller)
        
        return (
            controller,
            context,
            factories,
            loadingState
        )
    }
    
    // MARK: - Test Methods
    
    func test_preparing() async throws {
        
        let sut = createSUT()

        // Given
        let mediaId = UUID()
        
        // When
        await sut.controller.prepare(mediaId: mediaId)
        
        // Then
        verify(sut.factories.makeLoading(mediaId: mediaId, context: sut.context))
            .wasCalled(1)
        
        verify(sut.context.set(newState: sut.loadingState))
            .wasCalled(1)
    }
}

