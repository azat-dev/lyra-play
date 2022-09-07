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

//class LibraryCoordinatorTests: XCTestCase {
//    
//    typealias SUT = (
//        coordinator: LibraryCoordinator,
//        rootContainer: StackPresentationContainerMock,
//        view: AudioFilesBrowserViewMock,
//        viewModel: AudioFilesBrowserViewModelMock,
//        libraryItemCoordinator: LibraryItemCoordinatorMock
//    )
//
//    func createSUT(file: StaticString = #filePath, line: UInt = #line) -> SUT {
//
//        let rootContainer = mock(StackPresentationContainer.self)
//        
//        let viewModel = mock(AudioFilesBrowserViewModel.self)
//        let viewModelFactory = mock(AudioFilesBrowserViewModelFactory.self)
//
//        given(viewModelFactory.create(delegate: any()))
//            .willReturn(viewModel)
//
//        let view = mock(AudioFilesBrowserView.self)
//        let viewFactory = mock(AudioFilesBrowserViewFactory.self)
//        
//        given(viewFactory.create(viewModel: any()))
//            .willReturn(view)
//        
//        let libraryItemCoordinator = mock(LibraryItemCoordinator.self)
//        let libraryItemCoordinatorFactory = mock(LibraryItemCoordinatorFactory.self)
//        
//        given(libraryItemCoordinatorFactory.create())
//            .willReturn(libraryItemCoordinator)
//
//        let coordinator = LibraryCoordinatorImpl(
//            viewModelFactory: viewModelFactory,
//            viewFactory: viewFactory,
//            libraryItemCoordinatorFactory: libraryItemCoordinatorFactory
//        )
//
//        detectMemoryLeak(instance: coordinator, file: file, line: line)
//        addTeardownBlock {
//            reset(
//                rootContainer,
//                viewModel,
//                viewModelFactory,
//                view,
//                viewFactory,
//                libraryItemCoordinator,
//                libraryItemCoordinatorFactory
//            )
//        }
//
//        return (
//            coordinator,
//            rootContainer,
//            view,
//            viewModel,
//            libraryItemCoordinator
//        )
//    }
//    
//    func test_start__push_dictionary_view_on_start() {
//        
//        // Given
//        let sut = createSUT()
//        
//        // When
//        sut.coordinator.start(at: sut.rootContainer)
//        
//        // Then
//        verify(sut.rootContainer.setRoot(sut.view)).wasCalled(1)
//    }
//    
//    func test_runOpenLibraryItemFlow__without_start() {
//        
//        // Given
//        let sut = createSUT()
//        
//        // When
//        sut.coordinator.runOpenLibraryItemFlow(mediaId: UUID())
//        
//        // Then
//        verify(sut.libraryItemCoordinator.start(at: sut.rootContainer, mediaId: any())).wasNeverCalled()
//    }
//    
//    func test_runOpenLibraryItemFlow() {
//        
//        // Given
//        let sut = createSUT()
//        let mediaId = UUID()
//        
//        // When
//        sut.coordinator.start(at: sut.rootContainer)
//        sut.coordinator.runOpenLibraryItemFlow(mediaId: mediaId)
//        
//        // Then
//        verify(sut.libraryItemCoordinator.start(at: sut.rootContainer, mediaId: mediaId)).wasCalled(1)
//    }
//}
