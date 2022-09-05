//
//  MainTabBarCoordinatorTests.swift
//  LyraPlayTests
//
//  Created by Azat Kaiumov on 05.09.22.
//

import Foundation
import XCTest
import Mockingbird

import LyraPlay

class MainCoordinatorTests: XCTestCase {
    
    typealias SUT = (
        coordinator: MainCoordinator,
        mainTabBarCoordinator: MainTabBarCoordinatorMock,
        rootContainer: StackPresentationContainerMock
    )

    func createSUT(file: StaticString = #filePath, line: UInt = #line) -> SUT {

        let rootContainer = mock(StackPresentationContainer.self)
        
        let mainTabBarCoordinator = mock(MainTabBarCoordinator.self)
        
        let mainTabBarCoordinatorFactory = mock(MainTabBarCoordinatorFactory.self)
        given(mainTabBarCoordinatorFactory.create()).willReturn(mainTabBarCoordinator)
        
        let coordinator = MainCoordinatorImpl(
            mainTabBarCoordinatorFactory: mainTabBarCoordinatorFactory
        )

        detectMemoryLeak(instance: coordinator, file: file, line: line)
        
        addTeardownBlock {
            reset(
                rootContainer,
                mainTabBarCoordinator,
                mainTabBarCoordinatorFactory
            )
        }

        return (
            coordinator,
            mainTabBarCoordinator,
            rootContainer
        )
    }
    
    func test_start() {
        
        // Given
        let sut = createSUT()
        
        // When
        sut.coordinator.start(at: sut.rootContainer)
        
        // Then
        verify(sut.mainTabBarCoordinator.start(at: sut.rootContainer)).wasCalled(1)
    }
}
