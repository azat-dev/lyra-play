//
//  MainFlowPresenterTests.swift
//  LyraPlayTests
//
//  Created by Azat Kaiumov on 08.09.22.
//

import Foundation
import XCTest
import Mockingbird

import LyraPlay

class MainFlowPresenterTests: XCTestCase {
    
    typealias SUT = (
        presenter: MainFlowPresenter,
        flow: MainFlowModelMock,
        mainTabBarView: MainTabBarViewMock
    )
    
    func createSUT(file: StaticString = #filePath, line: UInt = #line) -> SUT {
        
        let viewModel = mock(MainTabBarViewModel.self)
        
        let mainTabBarView = mock(MainTabBarView.self)
        let mainTabBarViewFactory = mock(MainTabBarViewFactory.self)
        
        given(mainTabBarViewFactory.create(viewModel: viewModel))
            .willReturn(mainTabBarView)
        
        let flow = mock(MainFlowModel.self)
        
        given(flow.mainTabBarViewModel)
            .willReturn(viewModel)
        
        let presenter = MainFlowPresenterImpl(
            mainFlowModel: flow,
            mainTabBarViewFactory: mainTabBarViewFactory
        )
        
        detectMemoryLeak(instance: presenter)

        addTeardownBlock {
            reset(
                flow,
                viewModel,
                mainTabBarView,
                mainTabBarViewFactory
            )
        }
        
        return (
            presenter,
            flow,
            mainTabBarView
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
}
