//
//  AddMediaLibraryItemFlowModelTests.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 19.09.2022.
//

import Foundation
import XCTest
import Mockingbird
import LyraPlay

class AddMediaLibraryItemFlowModelTests: XCTestCase {

    typealias SUT = (
        flowModel: AddMediaLibraryItemFlowModelImpl,
        delegate: AddMediaLibraryItemFlowModelDelegateMock,
        chooseDialogViewModelFactory: ChooseDialogViewModelFactoryMock,
        importMediaFilesFlowModelFactory: ImportMediaFilesFlowModelFactoryMock
    )

    // MARK: - Methods

    func createSUT(targetFolderId: UUID) -> SUT {

        let delegate = mock(AddMediaLibraryItemFlowModelDelegate.self)

        let chooseDialogViewModel = mock(ChooseDialogViewModel.self)
        let chooseDialogViewModelFactory = mock(ChooseDialogViewModelFactory.self)
        
        given(chooseDialogViewModelFactory.create(items: any(), delegate: any()))
            .willReturn(chooseDialogViewModel)

        let importMediaFilesFlowModel = mock(ImportMediaFilesFlowModel.self)
        
        let importMediaFilesFlowModelFactory = mock(ImportMediaFilesFlowModelFactory.self)
        
        given(importMediaFilesFlowModelFactory.create(targetFolderId: any(), delegate: any()))
            .willReturn(importMediaFilesFlowModel)

        let flowModel = AddMediaLibraryItemFlowModelImpl(
            targetFolderId: targetFolderId,
            delegate: delegate,
            chooseDialogViewModelFactory: chooseDialogViewModelFactory,
            importMediaFilesFlowModelFactory: importMediaFilesFlowModelFactory
        )

        detectMemoryLeak(instance: flowModel)
        
        releaseMocks(
            delegate,
            chooseDialogViewModel,
            chooseDialogViewModelFactory,
            importMediaFilesFlowModelFactory,
            importMediaFilesFlowModel
        )

        return (
            flowModel: flowModel,
            delegate: delegate,
            chooseDialogViewModelFactory: chooseDialogViewModelFactory,
            importMediaFilesFlowModelFactory: importMediaFilesFlowModelFactory
        )
    }
    
    func test_open_choose_dialog() async throws {
        
        // Given
        let folderId = UUID()
        
        let sut = createSUT(targetFolderId: folderId)
        let chooseTypeFlowPromise = watch(sut.flowModel.chooseItemTypeViewModel, mapper: { $0 != nil })
        
        // When
        // Initilized
        
        // Then
        chooseTypeFlowPromise.expect([
            true
        ])
    }
    
    func test_run_import_flow() async throws {
        
        // Given
        let folderId = UUID()
        
        let sut = createSUT(targetFolderId: folderId)
        let importFlowPromise = watch(sut.flowModel.importMediaFilesFlow, mapper: { $0 != nil })
        
        // When
        sut.flowModel.chooseDialogViewModelDidChoose(itemId: "importMediaFiles")
        
        // Then
        importFlowPromise.expect([
            false,
            true
        ])
    }
}
