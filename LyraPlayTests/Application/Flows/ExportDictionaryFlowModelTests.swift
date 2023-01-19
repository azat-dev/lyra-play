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
        provideFileUrlUseCaseCallback: ProvideFileUrlUseCaseCallback?,
        fileSharingViewModelFactory: FileSharingViewModelFactoryMock,
        fileSharingViewModel: FileSharingViewModelMock,
        fileSharingViewModelDelegate: FileSharingViewModelDelegate?,
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
        
        var provideFileUrlUseCaseCallback: ProvideFileUrlUseCaseCallback?
        
        given(provideFileUrlUseCaseFactory.create(callback: any()))
            .will { callback in
                provideFileUrlUseCaseCallback = callback
                return provideFileUrlUseCase
            }
        
        let fileSharingViewModelFactory = mock(FileSharingViewModelFactory.self)
        let fileSharingViewModel = mock(FileSharingViewModel.self)
        
        var fileSharingViewModelDelegate: FileSharingViewModelDelegate?
        
        given(fileSharingViewModelFactory.create(delegate: any()))
            .will({ delegate in
                
                fileSharingViewModelDelegate = delegate
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
            fileSharingViewModel,
            fileSharingViewModelFactory,
            delegate
        )
        
        return (
            flowModel: flowModel,
            exportDictionaryUseCaseFactory: exportDictionaryUseCaseFactory,
            exportDictionaryUseCase: exportDictionaryUseCase,
            provideFileUrlUseCaseFactory: provideFileUrlUseCaseFactory,
            provideFileUrlUseCase: provideFileUrlUseCase,
            provideFileUrlUseCaseCallback: provideFileUrlUseCaseCallback,
            fileSharingViewModelFactory: fileSharingViewModelFactory,
            fileSharingViewModel: fileSharingViewModel,
            fileSharingViewModelDelegate: fileSharingViewModelDelegate,
            delegate: delegate
        )
    }
    
    func test_getFile() async throws {
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
//        let _ = sut.provideFileUrlUseCase.provideFileUrl()
//        
//        
//        // Then
//        let provideFileUrlUseCaseCallback = try XCTUnwrap(sut.provideFileUrlUseCaseCallback)
//        let receivedURL = provideFileUrlUseCaseCallback()
//        
//        verify(await sut.exportDictionaryUseCase.export())
//            .wasCalled()
    }
    
    func test_dispose() async throws {
        
        // Given
        let sut = createSUT()
        
        // When
        sut.fileSharingViewModelDelegate?.fileSharingViewModelDidDispose()
        
        // Then
        XCTAssertNil(sut.flowModel.fileSharingViewModel.value)
        verify(sut.delegate.exportDictionaryFlowModelDidDispose())
            .wasCalled()
        
    }
}
