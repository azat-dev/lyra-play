//
//  LibraryCoordinatorTests.swift
//  LyraPlayTests
//
//  Created by Azat Kaiumov on 26.08.22.
//

import Foundation
import XCTest
import Mockingbird

import LyraPlay

class LibraryCoordinatorTests: XCTestCase {
    
    typealias SUT = (
        coordinator: LibraryCoordinator,
        rootContainer: StackPresentationContainerMock,
        view: AudioFilesBrowserViewMock,
        viewModel: AudioFilesBrowserViewModelMock
    )

    func createSUT(file: StaticString = #filePath, line: UInt = #line) -> SUT {

        let rootContainer = mock(StackPresentationContainer.self)
        
        let viewModel = mock(AudioFilesBrowserViewModel.self)
        let viewModelFactory = mock(AudioFilesBrowserViewModelFactory.self)

        given(viewModelFactory.create(coordinator: any()))
            .willReturn(viewModel)

        let view = mock(AudioFilesBrowserView.self)
        let viewFactory = mock(AudioFilesBrowserViewFactory.self)
        

        given(viewFactory.create(viewModel: any()))
            .willReturn(view)

        let coordinator = LibraryCoordinatorImpl(
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
        verify(sut.rootContainer.setRoot(sut.view)).wasCalled()
    }
}
