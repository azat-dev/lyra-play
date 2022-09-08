//
//  MainFlowPresenterTests.swift
//  LyraPlayTests
//
//  Created by Azat Kaiumov on 08.09.22.
//

import Foundation
import XCTest
import Combine
import Mockingbird

import LyraPlay

class MainFlowPresenterTests: XCTestCase {
    
    typealias SUT = (
        presenter: MainFlowPresenter,
        flow: MainFlowModelMock,
        mainTabBarView: MainTabBarViewMock,
        libraryFlowPresenter: LibraryFlowPresenterMock,
        libraryContainer: StackPresentationContainerMock,
        libraryFlowSubject: CurrentValueSubject<LibraryFlowModel?, Never>
    )
    
    func createSUT(file: StaticString = #filePath, line: UInt = #line) -> SUT {
        
        let viewModel = mock(MainTabBarViewModel.self)
        let mainTabBarView = mock(MainTabBarView.self)
        
        let libraryContainer = mock(StackPresentationContainer.self)
        
        given(mainTabBarView.libraryContainer)
            .willReturn(libraryContainer)
        
        let mainTabBarViewFactory = mock(MainTabBarViewFactory.self)
        
        given(mainTabBarViewFactory.create(viewModel: viewModel))
            .willReturn(mainTabBarView)
        
        let flow = mock(MainFlowModel.self)
        
        given(flow.mainTabBarViewModel)
            .willReturn(viewModel)
        
        let libraryFlowSubject = CurrentValueSubject<LibraryFlowModel?, Never>(nil)
        
        given(flow.libraryFlow)
            .willReturn(libraryFlowSubject)
        
        let libraryFlowPresenter = mock(LibraryFlowPresenter.self)
        
        let libraryFlowPresenterFactory = mock(LibraryFlowPresenterFactory.self)
        given(libraryFlowPresenterFactory.create(for: any()))
            .willReturn(libraryFlowPresenter)
        
        let presenter = MainFlowPresenterImpl(
            mainFlowModel: flow,
            mainTabBarViewFactory: mainTabBarViewFactory,
            libraryFlowPresenterFactory: libraryFlowPresenterFactory
        )
        
        detectMemoryLeak(instance: presenter)

        releaseMocks(
            flow,
            viewModel,
            mainTabBarView,
            mainTabBarViewFactory,
            libraryFlowPresenterFactory,
            libraryFlowPresenter,
            libraryContainer
        )
        
        return (
            presenter,
            flow,
            mainTabBarView,
            libraryFlowPresenter,
            libraryContainer,
            libraryFlowSubject
        )
    }
    
    func test_setRoot() async throws {
        
        // Given
        let sut = createSUT()
        let window = mock(WindowContainer.self)
        
        // When
        sut.presenter.present(at: window)
        
        // Then
        verify(window.setRoot(sut.mainTabBarView))
            .wasCalled(1)
    }
    
    func test_present_library_flow() async throws {
        
        // Given
        let sut = createSUT()

        let window = mock(WindowContainer.self)
        sut.presenter.present(at: window)
        
        let libraryFlow = mock(LibraryFlowModel.self)
        
        // When
        sut.libraryFlowSubject.value = libraryFlow
        
        // Then
        verify(sut.libraryFlowPresenter.present(at: any()))
            .wasCalled(1)
    }
}
