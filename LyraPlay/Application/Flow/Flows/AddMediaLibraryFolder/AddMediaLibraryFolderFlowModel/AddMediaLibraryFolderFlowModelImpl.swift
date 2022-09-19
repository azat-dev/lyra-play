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

    private let browseMediaLibraryUseCaseFactory: BrowseMediaLibraryUseCaseFactory
    private let promptDialogViewModelFactory: PromptDialogViewModelFactory

    public let promptFolderNameViewModel = CurrentValueSubject<PromptDialogViewModel?, Never>(nil)

    // MARK: - Initializers

    public init(
        targetFolderId: UUID?,
        delegate: AddMediaLibraryFolderFlowModelDelegate,
        browseMediaLibraryUseCaseFactory: BrowseMediaLibraryUseCaseFactory,
        promptDialogViewModelFactory: PromptDialogViewModelFactory
    ) {

        self.targetFolderId = targetFolderId
        self.delegate = delegate
        self.browseMediaLibraryUseCaseFactory = browseMediaLibraryUseCaseFactory
        self.promptDialogViewModelFactory = promptDialogViewModelFactory
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
    
    public func promptDialogViewModelDidSubmit(value: String) {
        
        delegate?.addMediaLibraryFolderFlowModelDidCreate()
    }
    
    public func promptDialogViewModelDidDispose() {
        
        delegate?.addMediaLibraryFolderFlowModelDidDispose()
    }
}
