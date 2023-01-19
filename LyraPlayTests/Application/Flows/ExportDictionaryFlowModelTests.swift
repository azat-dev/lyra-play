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
        exportDictionaryUseCaseFactory: ExportDictionaryUseCaseFactoryMock,
        exportDictionaryUseCase: ExportDictionaryUseCaseMock,
        provideFileUrlUseCaseFactory: ProvideFileUrlUseCaseFactoryMock,
        provideFileUrlUseCase: ProvideFileUrlUseCaseMock,
        provideFileUrlUseCaseCallbackStore: StoreValue<ProvideFileUrlUseCaseCallback?>,
        fileSharingViewModelFactory: FileSharingViewModelFactoryMock,
        fileSharingViewModel: FileSharingViewModelMock,
        fileSharingViewModelDelegateStore: StoreValue<FileSharingViewModelDelegate?>,
        delegate: ExportDictionaryFlowModelDelegateMock
    )
    
    // MARK: - Methods
    
    func createSUT() -> SUT {
        
        let exportDictionaryUseCaseFactory = mock(ExportDictionaryUseCaseFactory.self)
        let exportDictionaryUseCase = mock(ExportDictionaryUseCase.self)
        
        given(exportDictionaryUseCaseFactory.create())
            .willReturn(exportDictionaryUseCase)
        
        let provideFileUrlUseCaseFactory = mock(ProvideFileUrlUseCaseFactory.self)
        let provideFileUrlUseCase = mock(ProvideFileUrlUseCase.self)
        
        
        let provideFileUrlUseCaseCallbackStore = StoreValue<ProvideFileUrlUseCaseCallback?>(nil)
        
        given(provideFileUrlUseCaseFactory.create(callback: any()))
            .will { callback in
                
                provideFileUrlUseCaseCallbackStore.value = callback
                return provideFileUrlUseCase
            }
        
        let fileSharingViewModelFactory = mock(FileSharingViewModelFactory.self)
        let fileSharingViewModel = mock(FileSharingViewModel.self)
        
        let fileSharingViewModelDelegateStore = StoreValue<FileSharingViewModelDelegate?>(nil)
        
        given(fileSharingViewModelFactory.create(delegate: any()))
            .will({ delegate in
                
                fileSharingViewModelDelegateStore.value = delegate
                return fileSharingViewModel
            })
        
        let delegate = mock(ExportDictionaryFlowModelDelegate.self)
        
        let flowModel = ExportDictionaryFlowModelImpl(
            exportDictionaryUseCaseFactory: exportDictionaryUseCaseFactory,
            provideFileUrlUseCaseFactory: provideFileUrlUseCaseFactory,
            fileSharingViewModelFactory: fileSharingViewModelFactory,
            delegate: delegate
        )
        
        detectMemoryLeak(instance: flowModel)
        
        releaseMocks(
            exportDictionaryUseCase,
            exportDictionaryUseCaseFactory,
            provideFileUrlUseCaseFactory,
            provideFileUrlUseCase,
            fileSharingViewModelFactory,
            fileSharingViewModel,
            delegate
        )
        
        addTeardownBlock {
            fileSharingViewModelDelegateStore.value = nil
            provideFileUrlUseCaseCallbackStore.value = nil
        }
        
        return (
            flowModel: flowModel,
            exportDictionaryUseCaseFactory: exportDictionaryUseCaseFactory,
            exportDictionaryUseCase: exportDictionaryUseCase,
            provideFileUrlUseCaseFactory: provideFileUrlUseCaseFactory,
            provideFileUrlUseCase: provideFileUrlUseCase,
            provideFileUrlUseCaseCallbackStore: provideFileUrlUseCaseCallbackStore,
            fileSharingViewModelFactory: fileSharingViewModelFactory,
            fileSharingViewModel: fileSharingViewModel,
            fileSharingViewModelDelegateStore: fileSharingViewModelDelegateStore,
            delegate: delegate
        )
    }
    
    func test_getFile() async throws {

        // Given
        let sut = createSUT()

        let exportedItems: [ExportedDictionaryItem] = [
            .init(
                original: "test",
                translations: [
                    "test"
                ]
            )
        ]

        given(await sut.exportDictionaryUseCase.export())
            .willReturn(.success(exportedItems))

        // When
        let _ = sut.flowModel.fileSharingViewModel
        
        let provideFileUrlUseCaseCallback = try XCTUnwrap(sut.provideFileUrlUseCaseCallbackStore.value)
        let _ = provideFileUrlUseCaseCallback()

        // Then
        verify(await sut.exportDictionaryUseCase.export())
            .wasCalled()
        
        verify(sut.provideFileUrlUseCase.provideFileUrl())
            .wasCalled()
    }
    
    func test_dispose() async throws {
        
        // Given
        let sut = createSUT()
        
        // When
        let _ = sut.flowModel.fileSharingViewModel
        sut.fileSharingViewModelDelegateStore.value?.fileSharingViewModelDidDispose()
        
        // Then
        verify(sut.delegate.exportDictionaryFlowModelDidDispose())
            .wasCalled()
    }
}

// MARK: - Helpers

public class StoreValue<T> {
    
    public var value: T
    
    public init(_ value: T) {
        self.value = value
    }
}
