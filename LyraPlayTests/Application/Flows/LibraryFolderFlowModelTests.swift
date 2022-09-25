//
//  LibraryFolderFlowModelTests.swift
//  LyraPlayTests
//
//  Created by Azat Kaiumov on 07.09.22.
//

import Foundation
import XCTest
import Mockingbird

import LyraPlay

class LibraryFolderFlowModelTests: XCTestCase {
    
    typealias SUT = (
        flow: LibraryFolderFlowModelImpl,
        listViewModel: MediaLibraryBrowserViewModelMock,
        libraryFileFlow: LibraryFileFlowModelMock,
        libraryFileFlowModelFactory: LibraryFileFlowModelFactoryMock
    )
    
    func createSUT(folderId: UUID?, file: StaticString = #filePath, line: UInt = #line) -> SUT {
        
        let viewModel = mock(MediaLibraryBrowserViewModel.self)
        let viewModelFactory = mock(MediaLibraryBrowserViewModelFactory.self)
        
        given(viewModelFactory.create(folderId: folderId, delegate: any()))
            .willReturn(viewModel)
        
        let libraryFileFlow = mock(LibraryFileFlowModel.self)
        let libraryFileFlowModelFactory = mock(LibraryFileFlowModelFactory.self)
        
        let addMediaLibraryItemFlowModelFactory = mock(AddMediaLibraryItemFlowModelFactory.self)
        
        given(libraryFileFlowModelFactory.create(for: any(), delegate: any()))
            .willReturn(libraryFileFlow)
        
        let deleteMediaLibraryItemFlowModelFactory = mock(DeleteMediaLibraryItemFlowModelFactory.self)
        
        let flow = LibraryFolderFlowModelImpl(
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
            libraryFileFlow,
            libraryFileFlowModelFactory,
            addMediaLibraryItemFlowModelFactory,
            deleteMediaLibraryItemFlowModelFactory
        )
        
        return (
            flow,
            viewModel,
            libraryFileFlow,
            libraryFileFlowModelFactory
        )
    }
    
    func test_runOpenLibraryItemFlow__open_file() {
        
        // Given
        let itemId = UUID()
        let sut = createSUT(folderId: nil)
        let libraryItemFlowSequence = expectSequence([false, true])
        
        given(sut.libraryFileFlowModelFactory.create(for: itemId, delegate: any()))
            .willReturn(sut.libraryFileFlow)
        
        let observer = sut.flow.libraryItemFlow.sink { value in
            
            switch value {

            case .none:
                libraryItemFlowSequence.fulfill(with: false)
                break

            case .file(let model):
                libraryItemFlowSequence.fulfill(with: model === sut.libraryFileFlow)
            }
        }
        
        // When
        sut.flow.runOpenLibraryItemFlow(itemId: itemId)
        
        // Then
        libraryItemFlowSequence.wait(timeout: 1, enforceOrder: true)
        observer.cancel()
    }
}
