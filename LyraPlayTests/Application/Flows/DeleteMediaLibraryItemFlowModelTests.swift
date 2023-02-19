//
//  DeleteMediaLibraryItemFlowModelTests.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 15.09.2022.
//

import Foundation
import XCTest
import Mockingbird
import LyraPlay

class DeleteMediaLibraryItemFlowModelTests: XCTestCase {

    typealias SUT = (
        flowModel: DeleteMediaLibraryItemFlowModelImpl,
        delegate: DeleteMediaLibraryItemFlowDelegateMock,
        editMediaLibraryListUseCase: EditMediaLibraryListUseCaseMock
    )

    // MARK: - Methods

    func createSUT(itemId: UUID) -> SUT {

        let delegate = mock(DeleteMediaLibraryItemFlowDelegate.self)
        
        let editMediaLibraryListUseCase = mock(EditMediaLibraryListUseCase.self)
        let editMediaLibraryListUseCaseFactory = mock(EditMediaLibraryListUseCaseFactory.self)
        
        given(editMediaLibraryListUseCaseFactory.make())
            .willReturn(editMediaLibraryListUseCase)
        
        
        let flowModel = DeleteMediaLibraryItemFlowModelImpl(
            itemId: itemId,
            delegate: delegate,
            editMediaLibraryListUseCaseFactory: editMediaLibraryListUseCaseFactory,
            confirmDialogViewModelFactory: ConfirmDialogViewModelImplFactory()
        )
        
        detectMemoryLeak(instance: flowModel)
        
        releaseMocks(
            delegate,
            editMediaLibraryListUseCaseFactory,
            editMediaLibraryListUseCase
        )

        return (
            flowModel: flowModel,
            delegate: delegate,
            editMediaLibraryListUseCase: editMediaLibraryListUseCase
        )
    }
    
    func test__cancel() async throws {

        // Given
        let mediaId = UUID()
        let sut = createSUT(itemId: mediaId)
        
        let confirmViewModel = try XCTUnwrap(sut.flowModel.confirmDialogViewModel.value)
        
        // When
        confirmViewModel.cancel()
        
        // Then
        verify(await sut.editMediaLibraryListUseCase.deleteItem(id: mediaId))
            .wasNeverCalled()
    }
    
    func test__confirm() async throws {

        // Given
        let mediaId = UUID()
        let sut = createSUT(itemId: mediaId)
        
        let confirmViewModel = try XCTUnwrap(sut.flowModel.confirmDialogViewModel.value)
        given(await sut.editMediaLibraryListUseCase.deleteItem(id: mediaId))
            .willReturn(.success(()))
        
        // When
        confirmViewModel.confirm()
        
        // Then
        verify(await sut.editMediaLibraryListUseCase.deleteItem(id: mediaId))
            .wasCalled(1)
    }
    
    func test__dispose() async throws {

        // Given
        let mediaId = UUID()
        let sut = createSUT(itemId: mediaId)
        
        let confirmViewModel = try XCTUnwrap(sut.flowModel.confirmDialogViewModel.value)
        
        // When
        confirmViewModel.dispose()
        
        // Then
        verify(await sut.editMediaLibraryListUseCase.deleteItem(id: mediaId))
            .wasNeverCalled()
    }
}
