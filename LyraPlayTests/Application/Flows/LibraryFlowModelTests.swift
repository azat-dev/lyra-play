//
//  LibraryFlowModelTests.swift
//  LyraPlayTests
//
//  Created by Azat Kaiumov on 07.09.22.
//

import Foundation
import XCTest
import Mockingbird

import LyraPlay

class LibraryFlowModelTests: XCTestCase {
    
    typealias SUT = (
        flow: LibraryFlowModelImpl,
        listViewModel: MediaLibraryBrowserViewModelMock,
        libraryItemFlow: LibraryFileFlowModelMock
    )
    
    func createSUT(folderId: UUID?, file: StaticString = #filePath, line: UInt = #line) -> SUT {
        
        let viewModel = mock(MediaLibraryBrowserViewModel.self)
        let viewModelFactory = mock(MediaLibraryBrowserViewModelFactory.self)
        
        given(viewModelFactory.create(folderId: folderId, delegate: any()))
            .willReturn(viewModel)
        
        let libraryItemFlow = mock(LibraryFileFlowModel.self)
        let libraryFileFlowModelFactory = mock(LibraryFileFlowModelFactory.self)
        
        let addMediaLibraryItemFlowModelFactory = mock(AddMediaLibraryItemFlowModelFactory.self)
        
        let delegate = mock(LibraryFileFlowModelDelegate.self)
        
        given(libraryFileFlowModelFactory.create(for: any(), delegate: delegate))
            .willReturn(libraryItemFlow)
        
        let deleteMediaLibraryItemFlowModelFactory = mock(DeleteMediaLibraryItemFlowModelFactory.self)
        
        let flow = LibraryFlowModelImpl(
            folderId: folderId,
            viewModelFactory: viewModelFactory,
            libraryFileFlowModelFactory: libraryFileFlowModelFactory,
            addMediaLibraryItemFlowModelFactory: addMediaLibraryItemFlowModelFactory,
            deleteMediaLibraryItemFlowModelFactory: deleteMediaLibraryItemFlowModelFactory
        )
        
        detectMemoryLeak(instance: flow)
        
        releaseMocks(
            viewModel,
            viewModelFactory,
            libraryItemFlow,
            libraryFileFlowModelFactory,
            delegate,
            addMediaLibraryItemFlowModelFactory,
            deleteMediaLibraryItemFlowModelFactory
        )
        
        return (
            flow,
            viewModel,
            libraryItemFlow
        )
    }
    
    func test_runOpenLibraryItemFlow() {
        
        let sut = createSUT(folderId: nil)
        let libraryItemFlowSequence = expectSequence([false, true])
        
        // Given
        let mediaId = UUID()
        
        let observer = sut.flow.libraryFileFlow.sink { value in
            
            libraryItemFlowSequence.fulfill(with: value === sut.libraryItemFlow)
        }

        // When
        sut.flow.runOpenLibraryItemFlow(mediaId: mediaId)
        
        // Then
        libraryItemFlowSequence.wait(timeout: 1, enforceOrder: true)
        observer.cancel()
    }
}
