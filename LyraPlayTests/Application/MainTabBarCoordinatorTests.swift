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

    func createSUT() -> SUT {

        let rootContainer = mock(StackPresentationContainer.self)
        
        let libraryCoordinator: LibraryCoordinatorMock = mock(LibraryCoordinator.self)

        let libraryCoordinatorFactory = mock(LibraryCoordinatorFactory.self)
        given(libraryCoordinatorFactory.create()).willReturn(libraryCoordinator as! LibraryCoordinator)


        let mainTabBarViewModel = mock(MainTabBarViewModel.self)
        let mainTabBarViewModelFactory = mock(MainTabBarViewModelFactory.self)
        
        let mainTabBarView = mock(MainTabBarView.self)
        let mainTabBarViewFactory = mock(MainTabBarViewFactory.self)
        
        given(mainTabBarViewFactory.create(viewModel: any())).willReturn(mainTabBarView as MainTabBarView)

        let coordinator: MainTabBarCoordinator = MainTabBarCoordinatorImpl(
            mainTabBarViewModelFactory: mainTabBarViewModelFactory,
            mainTabBarViewFactory: mainTabBarViewFactory,
            libraryCoordinatorFactory: libraryCoordinatorFactory
        )

        detectMemoryLeak(instance: coordinator)

        return (
            coordinator,
            rootContainer,
            libraryCoordinator,
            mainTabBarView
        )
    }
    
    func test_start_create_tabbar_view_on_start() {
        
        let sut = createSUT()
        
        sut.coordinator.start(at: sut.rootContainer)
        verify(sut.rootContainer.setRoot(sut.mainTabBarView)).wasCalled()
    }
}

