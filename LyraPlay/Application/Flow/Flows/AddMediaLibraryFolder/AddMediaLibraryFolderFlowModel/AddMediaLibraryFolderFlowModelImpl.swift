//
//  AddMediaLibraryFolderFlowModelImpl.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 19.09.2022.
//

import Foundation
import Combine

public final class AddMediaLibraryFolderFlowModelImpl: AddMediaLibraryFolderFlowModel {

    // MARK: - Properties

    private let targetFolderId: UUID?
    private weak var delegate: AddMediaLibraryFolderFlowModelDelegate? 

    private let editMediaLibraryListUseCaseFactory: EditMediaLibraryListUseCaseFactory
    private let promptDialogViewModelFactory: PromptDialogViewModelFactory

    public let promptFolderNameViewModel = CurrentValueSubject<PromptDialogViewModel?, Never>(nil)

    // MARK: - Initializers

    public init(
        targetFolderId: UUID?,
        delegate: AddMediaLibraryFolderFlowModelDelegate,
        editMediaLibraryListUseCaseFactory: EditMediaLibraryListUseCaseFactory,
        promptDialogViewModelFactory: PromptDialogViewModelFactory
    ) {

        self.targetFolderId = targetFolderId
        self.delegate = delegate
        self.editMediaLibraryListUseCaseFactory = editMediaLibraryListUseCaseFactory
        self.promptDialogViewModelFactory = promptDialogViewModelFactory
        
        showPromptDialog()
    }
    
    private func showPromptDialog() {
        
        let promptViewModel = promptDialogViewModelFactory.create(
            messageText: "Create a new folder",
            submitText: "Create",
            cancelText: "Cancel",
            delegate: self
        )
        
        promptFolderNameViewModel.value = promptViewModel
    }
}

// MARK: - PromptDialogViewModelDelegate

extension AddMediaLibraryFolderFlowModelImpl: PromptDialogViewModelDelegate {

    public func promptDialogViewModelDidCancel() {

        promptFolderNameViewModel.value = nil
        delegate?.addMediaLibraryFolderFlowModelCancel()
    }
    
    private func createFolder(name: String) async {
        
        let editMediaLibraryListUseCase = editMediaLibraryListUseCaseFactory.create()
        
        let folderData = NewMediaLibraryFolderData(
            parentId: targetFolderId,
            title: name,
            image: nil
        )
        
        let result = await editMediaLibraryListUseCase.addFolder(data: folderData)
        
        switch result {
            
        case .success:
            delegate?.addMediaLibraryFolderFlowModelDidCreate()

        case .failure(.nameMustBeUnique):
            promptFolderNameViewModel.value?.setErrorText("The name of a folder must be unique")
            
        case .failure:
            // TODO: Handle errors
            break
        }
    }
    
    public func promptDialogViewModelDidSubmit(value: String) {
        
        Task {
            await self.createFolder(name: value)
        }
    }
    
    public func promptDialogViewModelDidDispose() {
        
        delegate?.addMediaLibraryFolderFlowModelDidDispose()
    }
}
