//
//  LibraryItemCoordinatorTests.swift
//  LyraPlayTests
//
//  Created by Azat Kaiumov on 27.08.22.
//

import Foundation
import XCTest
import Mockingbird

import LyraPlay

class LibraryItemCoordinatorTests: XCTestCase {
    
    typealias SUT = (
        coordinator: LibraryItemCoordinator,
        rootContainer: StackPresentationContainerMock,
        view: LibraryItemViewMock,
        viewModel: LibraryItemViewModelMock
    )

    func createSUT(file: StaticString = #filePath, line: UInt = #line) -> SUT {

        let rootContainer = mock(StackPresentationContainer.self)
        
        let viewModel = mock(LibraryItemViewModel.self)
        let viewModelFactory = mock(LibraryItemViewModelFactory.self)

        given(viewModelFactory.create(mediaId: any(), coordinator: any()))
            .willReturn(viewModel)

        let view = mock(LibraryItemView.self)
        let viewFactory = mock(LibraryItemViewFactory.self)
        

        given(viewFactory.create(viewModel: any()))
            .willReturn(view)

        let coordinator = LibraryItemCoordinatorImpl(
            viewModelFactory: viewModelFactory,
            viewFactory: viewFactory
        )

        detectMemoryLeak(instance: coordinator, file: file, line: line)
        releaseMocks(
            rootContainer,
            viewModel,
            viewModelFactory,
            view,
            viewFactory
        )

        return (
            coordinator,
            rootContainer,
            view,
            viewModel
        )
    }
    
    func test_start__push_view_on_start() {
        
        // Given
        let sut = createSUT()
        
        // When
        sut.coordinator.start(at: sut.rootContainer, mediaId: UUID())
        
        // Then
        verify(sut.rootContainer.push(sut.view)).wasCalled(1)
    }
}
