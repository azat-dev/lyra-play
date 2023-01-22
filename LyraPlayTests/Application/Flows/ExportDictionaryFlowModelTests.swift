//
//  ExportDictionaryFlowModelTests.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 19.01.2023.
//

import Foundation
import XCTest
import Mockingbird
import LyraPlay

class ExportDictionaryFlowModelTests: XCTestCase {
    
    typealias SUT = (
        flowModel: ExportDictionaryFlowModel,
        fileSharingViewModelFactory: FileSharingViewModelFactoryMock,
        fileSharingViewModel: FileSharingViewModelMock,
        fileSharingViewModelDelegateStore: ValueStore<FileSharingViewModelDelegate>,
        delegate: ExportDictionaryFlowModelDelegateMock
    )
    
    // MARK: - Methods
    
    func createSUT() -> SUT {
        
        let fileSharingViewModelFactory = mock(FileSharingViewModelFactory.self)
        let fileSharingViewModel = mock(FileSharingViewModel.self)
        
        let fileSharingViewModelDelegateStore = ValueStore<FileSharingViewModelDelegate>()
        
        given(fileSharingViewModelFactory.create(fileName: any(), delegate: any()))
            .will { _, delegate in
                fileSharingViewModelDelegateStore.value = delegate
                return fileSharingViewModel
            }
        
        let delegate = mock(ExportDictionaryFlowModelDelegate.self)
        
        let flowModel = ExportDictionaryFlowModelImpl(
            outputFileName: "test.dict",
            fileSharingViewModelFactory: fileSharingViewModelFactory,
            delegate: delegate
        )
        
        detectMemoryLeak(instance: flowModel)
        
        releaseMocks(
            fileSharingViewModelFactory,
            fileSharingViewModel,
            delegate
        )
        
        addTeardownBlock {
            fileSharingViewModelDelegateStore.value = nil
        }
        
        return (
            flowModel: flowModel,
            fileSharingViewModelFactory: fileSharingViewModelFactory,
            fileSharingViewModel: fileSharingViewModel,
            fileSharingViewModelDelegateStore: fileSharingViewModelDelegateStore,
            delegate: delegate
        )
    }
    
    func test_dispose() async throws {
        
        // Given
        let sut = createSUT()
        
        // When
        let _ = sut.flowModel.fileSharingViewModel
        let fileSharingViewModelDelegate = try XCTUnwrap(sut.fileSharingViewModelDelegateStore.value)
        fileSharingViewModelDelegate.fileSharingViewModelDidDispose()
        
        // Then
        verify(sut.delegate.exportDictionaryFlowModelDidDispose())
            .wasCalled()
    }
}

// MARK: - Helpers

class ValueStore<T> {
    
    var value: T?
    
    init() {}
}
