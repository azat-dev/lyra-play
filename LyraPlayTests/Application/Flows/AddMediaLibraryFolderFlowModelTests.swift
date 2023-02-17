//
//  AddMediaLibraryFolderFlowModelTests.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 19.09.2022.
//

import Foundation
import XCTest
import Mockingbird
import LyraPlay

class AddMediaLibraryFolderFlowModelTests: XCTestCase {

    typealias SUT = (
        flowModel: AddMediaLibraryFolderFlowModelImpl,
        delegate: AddMediaLibraryFolderFlowModelDelegateMock,
        editMediaLibraryListUseCaseFactory: EditMediaLibraryListUseCaseFactoryMock,
        promptDialogViewModelFactory: PromptDialogViewModelFactoryMock,
        promptDialogViewModel: PromptDialogViewModelMock,
        editMediaLibraryListUseCase: EditMediaLibraryListUseCaseMock
    )

    // MARK: - Methods

    func createSUT(targetFolderId: UUID?) -> SUT {

        let delegate = mock(AddMediaLibraryFolderFlowModelDelegate.self)

        let editMediaLibraryListUse = mock(EditMediaLibraryListUseCase.self)
        
        let editMediaLibraryListUseCaseFactory = mock(EditMediaLibraryListUseCaseFactory.self)
        given(editMediaLibraryListUseCaseFactory.make())
            .willReturn(editMediaLibraryListUse)

        let promptDialogViewModel = mock(PromptDialogViewModel.self)
        
        let promptDialogViewModelFactory = mock(PromptDialogViewModelFactory.self)
        given(
            promptDialogViewModelFactory.make(
                messageText: any(),
                submitText: any(),
                cancelText: any(),
                delegate: any()
            )
        ).willReturn(promptDialogViewModel)
        
        let flowModel = AddMediaLibraryFolderFlowModelImpl(
            targetFolderId: targetFolderId,
            delegate: delegate,
            editMediaLibraryListUseCaseFactory: editMediaLibraryListUseCaseFactory,
            promptDialogViewModelFactory: promptDialogViewModelFactory
        )

        detectMemoryLeak(instance: flowModel)
        
        releaseMocks(
            delegate,
            editMediaLibraryListUseCaseFactory,
            promptDialogViewModel,
            promptDialogViewModelFactory,
            editMediaLibraryListUse
        )

        return (
            flowModel: flowModel,
            delegate: delegate,
            editMediaLibraryListUseCaseFactory: editMediaLibraryListUseCaseFactory,
            promptDialogViewModelFactory: promptDialogViewModelFactory,
            promptDialogViewModel,
            editMediaLibraryListUse
        )
    }
    
    func test_show_prompt() {
        
        // Given
        let targetFolderId = UUID()
        
        let sut = createSUT(targetFolderId: targetFolderId)
        let promisePrompt = watch(sut.flowModel.promptFolderNameViewModel, mapper: { $0 != nil})
        
        // When
        // Initialized
        
        // Then
        promisePrompt.expect([
            true
        ])
    }
    
    func test_cancel_prompt() {
        
        // Given
        let targetFolderId = UUID()
        
        let sut = createSUT(targetFolderId: targetFolderId)
        let promisePrompt = watch(sut.flowModel.promptFolderNameViewModel, mapper: { $0 != nil})
        
        // When
        sut.flowModel.promptDialogViewModelDidCancel()
        
        // Then
        promisePrompt.expect([
            true,
            false
        ])
    }
    
    func test_submit_prompt__existing_name() async throws {
        
        // Given
        let targetFolderId = UUID()
        let existingName = "test"
        
        let sut = createSUT(targetFolderId: targetFolderId)
        
        given(await sut.editMediaLibraryListUseCase.addFolder(data: any()))
            .willReturn(.failure(.nameMustBeUnique))
        
        given(sut.promptDialogViewModel.setErrorText(any()))
            .willReturn(())
        
        // When
        sut.flowModel.promptDialogViewModelDidSubmit(value: existingName)
        
        // Then
        verify(sut.promptDialogViewModel.setErrorText(any()))
            .wasCalled(1)
    }
    
    func test_submit_prompt() async throws {
        
        // Given
        let targetFolderId = UUID()
        let existingName = "test"
        let newFolderData = NewMediaLibraryFolderData(
            parentId: targetFolderId,
            title: existingName,
            image: nil
        )
        
        let createdFolder = MediaLibraryFolder(
            id: UUID(),
            parentId: targetFolderId,
            createdAt: .now,
            updatedAt: nil,
            title: existingName,
            image: nil
        )
        
        let sut = createSUT(targetFolderId: targetFolderId)
        
        given(await sut.editMediaLibraryListUseCase.addFolder(data: newFolderData))
            .willReturn(.success(createdFolder))
        
        given(sut.promptDialogViewModel.setErrorText(any()))
            .willReturn(())
        
        // When
        sut.flowModel.promptDialogViewModelDidSubmit(value: existingName)
        
        // Then
        verify(sut.promptDialogViewModel.setErrorText(any()))
            .wasNeverCalled()
        
        verify(
            await sut.editMediaLibraryListUseCase.addFolder(
                data: .init(
                    parentId: targetFolderId,
                    title: existingName,
                    image: nil
                )
            )
        ).wasCalled(1)
    }
}
