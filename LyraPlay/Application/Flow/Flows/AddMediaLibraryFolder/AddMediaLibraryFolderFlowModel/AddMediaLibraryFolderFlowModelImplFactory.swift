//
//  AddMediaLibraryFolderFlowModelImplFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 19.09.2022.
//

import Foundation

public final class AddMediaLibraryFolderFlowModelImplFactory: AddMediaLibraryFolderFlowModelFactory {

    // MARK: - Properties

    private let browseMediaLibraryUseCaseFactory: BrowseMediaLibraryUseCaseFactory
    private let promptDialogViewModelFactory: PromptDialogViewModelFactory

    // MARK: - Initializers

    public init(
        browseMediaLibraryUseCaseFactory: BrowseMediaLibraryUseCaseFactory,
        promptDialogViewModelFactory: PromptDialogViewModelFactory
    ) {

        self.browseMediaLibraryUseCaseFactory = browseMediaLibraryUseCaseFactory
        self.promptDialogViewModelFactory = promptDialogViewModelFactory
    }

    // MARK: - Methods

    public func create(
        targetFolderId: UUID?,
        delegate: AddMediaLibraryFolderFlowModelDelegate
    ) -> AddMediaLibraryFolderFlowModel {

        return AddMediaLibraryFolderFlowModelImpl(
            targetFolderId: targetFolderId,
            delegate: delegate,
            browseMediaLibraryUseCaseFactory: browseMediaLibraryUseCaseFactory,
            promptDialogViewModelFactory: promptDialogViewModelFactory
        )
    }
}
