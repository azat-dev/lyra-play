//
//  DictionaryCoordinatorTests.swift
//  LyraPlayTests
//
//  Created by Azat Kaiumov on 05.09.22.
//

import Foundation
import XCTest
import Mockingbird

import LyraPlay

class DictionaryCoordinatorTests: XCTestCase {
    
    typealias SUT = (
        coordinator: DictionaryCoordinator,
        rootContainer: StackPresentationContainerMock,
        dictionaryView: DictionaryListBrowserViewMock,
        dictionaryViewModel: DictionaryListBrowserViewModelMock
    )

    func createSUT(file: StaticString = #filePath, line: UInt = #line) -> SUT {

        let rootContainer = mock(StackPresentationContainer.self)
        
        let viewModel = mock(DictionaryListBrowserViewModel.self)
        let viewModelFactory = mock(DictionaryListBrowserViewModelFactory.self)

        given(viewModelFactory.create(coordinator: any())).willReturn(viewModel)

        let view = mock(DictionaryListBrowserView.self)
        let viewFactory = mock(DictionaryListBrowserViewFactory.self)
        

        given(viewFactory.create(viewModel: any())).willReturn(view as DictionaryListBrowserView)

        let coordinator = DictionaryCoordinatorImpl(
            viewModelFactory: viewModelFactory,
            viewFactory: viewFactory
        )

        detectMemoryLeak(instance: coordinator, file: file, line: line)
        addTeardownBlock {
            reset(
                rootContainer,
                viewModel,
                viewModelFactory,
                view,
                viewFactory
            )
        }

        return (
            coordinator,
            rootContainer,
            view,
            viewModel
        )
    }
    
    func test_start__push_dictionary_view_on_start() {
        
        // Given
        let sut = createSUT()
        
        // When
        sut.coordinator.start(at: sut.rootContainer)
        
        // Then
        verify(sut.rootContainer.push(sut.dictionaryView)).wasCalled()
    }
}
