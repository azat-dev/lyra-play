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
        libraryItemFlow: LibraryItemFlowModelMock
    )
    
    func createSUT(file: StaticString = #filePath, line: UInt = #line) -> SUT {
        
        let viewModel = mock(MediaLibraryBrowserViewModel.self)
        let viewModelFactory = mock(MediaLibraryBrowserViewModelFactory.self)
        
        given(viewModelFactory.create(delegate: any()))
            .willReturn(viewModel)
        
        let libraryItemFlow = mock(LibraryItemFlowModel.self)
        let libraryItemFlowModelFactory = mock(LibraryItemFlowModelFactory.self)
        
        let importMediaFilesFlowModelFactory = mock(ImportMediaFilesFlowModelFactory.self)
        
        let delegate = mock(LibraryItemFlowModelDelegate.self)
        
        given(libraryItemFlowModelFactory.create(for: any(), delegate: delegate))
            .willReturn(libraryItemFlow)
        
        let flow = LibraryFlowModelImpl(
            viewModelFactory: viewModelFactory,
            libraryItemFlowModelFactory: libraryItemFlowModelFactory,
            importMediaFilesFlowModelFactory: importMediaFilesFlowModelFactory
        )
        
        detectMemoryLeak(instance: flow)
        
        releaseMocks(
            viewModel,
            viewModelFactory,
            libraryItemFlow,
            libraryItemFlowModelFactory,
            delegate,
            importMediaFilesFlowModelFactory
        )
        
        return (
            flow,
            viewModel,
            libraryItemFlow
        )
    }
    
    func test_runOpenLibraryItemFlow() {
        
        let sut = createSUT()
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
