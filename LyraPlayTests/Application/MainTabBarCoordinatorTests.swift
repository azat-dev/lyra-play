//
//  MainTabBarCoordinatorTests.swift
//  LyraPlayTests
//
//  Created by Azat Kaiumov on 04.09.22.
//

import Foundation
import XCTest
import Mockingbird

import LyraPlay

class MainTabBarCoordinatorTests: XCTestCase {
    
    typealias SUT = (
        coordinator: MainTabBarCoordinator,
        rootContainer: StackPresentationContainerMock,
        libraryCoordinator: LibraryCoordinatorMock,
        mainTabBarView: MainTabBarView
    )

    func createSUT(file: StaticString = #filePath, line: UInt = #line) -> SUT {

        let rootContainer = mock(StackPresentationContainer.self)
        
        let libraryCoordinator: LibraryCoordinatorMock = mock(LibraryCoordinator.self)

        let libraryCoordinatorFactory = mock(LibraryCoordinatorFactory.self)
        given(libraryCoordinatorFactory.create()).willReturn(libraryCoordinator as! LibraryCoordinator)


        let mainTabBarViewModel = mock(MainTabBarViewModel.self)
        let mainTabBarViewModelFactory = mock(MainTabBarViewModelFactory.self)

        given(mainTabBarViewModelFactory.create(coordinator: any())).willReturn(mainTabBarViewModel)

        let mainTabBarView = mock(MainTabBarView.self)
        let mainTabBarViewFactory = mock(MainTabBarViewFactory.self)

        given(mainTabBarViewFactory.create(viewModel: any())).willReturn(mainTabBarView as MainTabBarView)

        let coordinator = MainTabBarCoordinatorImpl(
            mainTabBarViewModelFactory: mainTabBarViewModelFactory,
            mainTabBarViewFactory: mainTabBarViewFactory,
            libraryCoordinatorFactory: libraryCoordinatorFactory
        )

        detectMemoryLeak(instance: coordinator, file: file, line: line)
        addTeardownBlock {
            reset(
                rootContainer,
                libraryCoordinator,
                libraryCoordinatorFactory,
                mainTabBarView,
                mainTabBarViewModel,
                mainTabBarViewModelFactory,
                mainTabBarViewFactory
            )
        }

        return (
            coordinator,
            rootContainer,
            libraryCoordinator,
            mainTabBarView
        )
    }
    
    func test_start__create_tabbar_view_on_start() {
        
        // Given
        let sut = createSUT()
        
        // When
        sut.coordinator.start(at: sut.rootContainer)
        
        // Then
        verify(sut.rootContainer.setRoot(sut.mainTabBarView)).wasCalled()
    }
    
    func test_runLibraryFlow() {
        
        // Given
        let sut = createSUT()
        
        // When
        sut.coordinator.runLibraryFlow()
        sut.coordinator.runLibraryFlow()
        
        // Then
        verify(sut.libraryCoordinator.start(at: sut.mainTabBarView.libraryContainer)).wasCalled(1)
    }
}
