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
    
//    typealias SUT = (
//        flowModel: ExportDictionaryFlowModel,
//        exportDictionaryUseCaseFactory: ExportDictionaryUseCaseFactoryMock,
//        exportDictionaryUseCase: ExportDictionaryUseCaseMock,
//        provideFileForSharingUseCaseFactory: ProvideFileForSharingUseCaseFactoryMock,
//        provideFileForSharingUseCase: ProvideFileForSharingUseCaseMock,
//        fileSharingViewModelFactory: FileSharingViewModelFactoryMock,
//        fileSharingViewModel: FileSharingViewModelMock,
//        fileSharingViewModelDelegateStore: StoreValue<FileSharingViewModelDelegate?>,
//        delegate: ExportDictionaryFlowModelDelegateMock
//    )
//    
//    // MARK: - Methods
//    
//    func createSUT() -> SUT {
//        
//        let exportDictionaryUseCaseFactory = mock(ExportDictionaryUseCaseFactory.self)
//        let exportDictionaryUseCase = mock(ExportDictionaryUseCase.self)
//        
//        given(exportDictionaryUseCaseFactory.create())
//            .willReturn(exportDictionaryUseCase)
//        
//        let provideFileForSharingUseCaseFactory = mock(ProvideFileForSharingUseCaseFactory.self)
//        let provideFileForSharingUseCase = mock(ProvideFileForSharingUseCase.self)
//        
//        given(provideFileForSharingUseCaseFactory.create(callback: any()))
//            .willReturn(provideFileForSharingUseCase)
//        
//        let fileSharingViewModelFactory = mock(FileSharingViewModelFactory.self)
//        let fileSharingViewModel = mock(FileSharingViewModel.self)
//        
//        let fileSharingViewModelDelegateStore = StoreValue<FileSharingViewModelDelegate?>(nil)
//        
//        given(fileSharingViewModelFactory.create(delegate: any()))
//            .will({ delegate in
//                
//                fileSharingViewModelDelegateStore.value = delegate
//                return fileSharingViewModel
//            })
//        
//        let delegate = mock(ExportDictionaryFlowModelDelegate.self)
//        
//        let flowModel = ExportDictionaryFlowModelImpl(
//            exportDictionaryUseCaseFactory: exportDictionaryUseCaseFactory,
//            provideFileForSharingUseCaseFactory: provideFileForSharingUseCaseFactory,
//            fileSharingViewModelFactory: fileSharingViewModelFactory,
//            delegate: delegate
//        )
//        
//        detectMemoryLeak(instance: flowModel)
//        
//        releaseMocks(
//            exportDictionaryUseCase,
//            exportDictionaryUseCaseFactory,
//            provideFileForSharingUseCaseFactory,
//            provideFileForSharingUseCase,
//            fileSharingViewModelFactory,
//            fileSharingViewModel,
//            delegate
//        )
//        
//        addTeardownBlock {
//            fileSharingViewModelDelegateStore.value = nil
//            provideFileForSharingUseCaseCallbackStore.value = nil
//        }
//        
//        return (
//            flowModel: flowModel,
//            exportDictionaryUseCaseFactory: exportDictionaryUseCaseFactory,
//            exportDictionaryUseCase: exportDictionaryUseCase,
//            provideFileForSharingUseCaseFactory: provideFileForSharingUseCaseFactory,
//            provideFileForSharingUseCase: provideFileForSharingUseCase,
//            provideFileForSharingUseCaseCallbackStore: provideFileForSharingUseCaseCallbackStore,
//            fileSharingViewModelFactory: fileSharingViewModelFactory,
//            fileSharingViewModel: fileSharingViewModel,
//            fileSharingViewModelDelegateStore: fileSharingViewModelDelegateStore,
//            delegate: delegate
//        )
//    }
//    
//    func test_getFile() async throws {
//
//        // Given
//        let sut = createSUT()
//
//        let exportedItems: [ExportedDictionaryItem] = [
//            .init(
//                original: "test",
//                translations: [
//                    "test"
//                ]
//            )
//        ]
//
//        given(await sut.exportDictionaryUseCase.export())
//            .willReturn(.success(exportedItems))
//
//        // When
//        let _ = sut.flowModel.fileSharingViewModel
//        sut.flowModel.fileSharingViewModel.value?.putFile(at: <#T##URL#>)
//        
//        
//        let provideFileForSharingUseCaseCallback = try XCTUnwrap(sut.provideFileForSharingUseCaseCallbackStore.value)
//        let _ = provideFileForSharingUseCaseCallback()
//
//        // Then
//        verify(sut.exportDictionaryUseCase.export())
//            .wasCalled()
//        
//        verify(sut.provideFileForSharingUseCase.provideFileUrl())
//            .wasCalled()
//    }
//    
//    func test_dispose() async throws {
//        
//        // Given
//        let sut = createSUT()
//        
//        // When
//        let _ = sut.flowModel.fileSharingViewModel
//        sut.fileSharingViewModelDelegateStore.value?.fileSharingViewModelDidDispose()
//        
//        // Then
//        verify(sut.delegate.exportDictionaryFlowModelDidDispose())
//            .wasCalled()
//    }
}
