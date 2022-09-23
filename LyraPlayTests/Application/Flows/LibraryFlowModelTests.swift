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
        libraryItemFlow: LibraryFolderFlowModelMock
    )
    
    func createSUT(folderId: UUID?, file: StaticString = #filePath, line: UInt = #line) -> SUT {
        
        let viewModel = mock(MediaLibraryBrowserViewModel.self)
        let viewModelFactory = mock(MediaLibraryBrowserViewModelFactory.self)
        
        given(viewModelFactory.create(folderId: folderId, delegate: any()))
            .willReturn(viewModel)
        
        let libraryItemFlow = mock(LibraryFolderFlowModel.self)
        let libraryItemFlowModelFactory = mock(LibraryFolderFlowModelFactory.self)
        
        let addMediaLibraryItemFlowModelFactory = mock(AddMediaLibraryItemFlowModelFactory.self)
        
        let delegate = mock(LibraryFolderFlowModelDelegate.self)
        
        given(libraryItemFlowModelFactory.create(for: any(), delegate: delegate))
            .willReturn(libraryItemFlow)
        
        let deleteMediaLibraryItemFlowModelFactory = mock(DeleteMediaLibraryItemFlowModelFactory.self)
        
        let flow = LibraryFlowModelImpl(
            folderId: folderId,
            viewModelFactory: viewModelFactory,
            libraryItemFlowModelFactory: libraryItemFlowModelFactory,
            addMediaLibraryItemFlowModelFactory: addMediaLibraryItemFlowModelFactory,
            deleteMediaLibraryItemFlowModelFactory: deleteMediaLibraryItemFlowModelFactory
        )
        
        detectMemoryLeak(instance: flow)
        
        releaseMocks(
            viewModel,
            viewModelFactory,
            libraryItemFlow,
            libraryItemFlowModelFactory,
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
        
        let observer = sut.flow.libraryItemFlow.sink { value in
            
            libraryItemFlowSequence.fulfill(with: value === sut.libraryItemFlow)
        }

        // When
        sut.flow.runOpenLibraryItemFlow(mediaId: mediaId)
        
        // Then
        libraryItemFlowSequence.wait(timeout: 1, enforceOrder: true)
        observer.cancel()
    }
}
