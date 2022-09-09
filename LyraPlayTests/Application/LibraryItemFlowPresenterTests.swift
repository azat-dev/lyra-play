//
//  LibraryItemFlowPresenterTests.swift
//  LyraPlayTests
//
//  Created by Azat Kaiumov on 09.09.22.
//

import Foundation
import XCTest
import Combine
import Mockingbird

import LyraPlay

class LibraryItemFlowPresenterTests: XCTestCase {
    
    typealias SUT = (
        presenter: LibraryItemFlowPresenter,
        flow: LibraryItemFlowModelMock,
        view: LibraryItemViewMock
    )
    
    func createSUT(file: StaticString = #filePath, line: UInt = #line) -> SUT {
        
        let viewModel = mock(LibraryItemViewModel.self)
        let view = mock(LibraryItemView.self)
        
        let viewFactory = mock(LibraryItemViewFactory.self)
        
        given(viewFactory.create(viewModel: any()))
            .willReturn(view)
        
        let flow = mock(LibraryItemFlowModel.self)
        
        given(flow.viewModel)
            .willReturn(viewModel)


        let presenter = LibraryItemFlowPresenterImpl(
            flowModel: flow,
            libraryItemViewFactory: viewFactory
        )
        
        detectMemoryLeak(instance: presenter)

        releaseMocks(
            flow,
            viewModel,
            view,
            viewFactory
        )
        
        return (
            presenter,
            flow,
            view
        )
    }
    
    func test_push() async throws {
        
        // Given
        let sut = createSUT()
        let container = mock(StackPresentationContainer.self)
        
        // When
        sut.presenter.present(at: container)
        
        // Then
        verify(container.push(sut.view))
            .wasCalled(1)
    }
}
