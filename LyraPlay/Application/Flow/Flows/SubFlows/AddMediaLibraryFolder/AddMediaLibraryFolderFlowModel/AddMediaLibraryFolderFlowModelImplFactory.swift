//
//  AddMediaLibraryFolderFlowModelImplFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 19.09.2022.
//

import Foundation

public final class AddMediaLibraryFolderFlowModelImplFactory: AddMediaLibraryFolderFlowModelFactory {

    // MARK: - Properties

    private let editMediaLibraryListUseCaseFactory: EditMediaLibraryListUseCaseFactory
    private let promptDialogViewModelFactory: PromptDialogViewModelFactory

    // MARK: - Initializers

    public init(
        editMediaLibraryListUseCaseFactory: EditMediaLibraryListUseCaseFactory,
        promptDialogViewModelFactory: PromptDialogViewModelFactory
    ) {

        self.editMediaLibraryListUseCaseFactory = editMediaLibraryListUseCaseFactory
        self.promptDialogViewModelFactory = promptDialogViewModelFactory
    }

    // MARK: - Methods

    public func make(
        targetFolderId: UUID?,
        delegate: AddMediaLibraryFolderFlowModelDelegate
    ) -> AddMediaLibraryFolderFlowModel {

        return AddMediaLibraryFolderFlowModelImpl(
            targetFolderId: targetFolderId,
            delegate: delegate,
            editMediaLibraryListUseCaseFactory: editMediaLibraryListUseCaseFactory,
            promptDialogViewModelFactory: promptDialogViewModelFactory
        )
    }
}
