//
//  AddMediaLibraryItemFlowModelImplFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 19.09.2022.
//

import Foundation

public final class AddMediaLibraryItemFlowModelImplFactory: AddMediaLibraryItemFlowModelFactory {

    // MARK: - Properties

    private let chooseDialogViewModelFactory: ChooseDialogViewModelFactory
    private let importMediaFilesFlowModelFactory: ImportMediaFilesFlowModelFactory
    private let addMediaLibraryFolderFlowModelFactory: AddMediaLibraryFolderFlowModelImplFactory
    
    // MARK: - Initializers

    public init(
        chooseDialogViewModelFactory: ChooseDialogViewModelFactory,
        importMediaFilesFlowModelFactory: ImportMediaFilesFlowModelFactory,
        addMediaLibraryFolderFlowModelFactory: AddMediaLibraryFolderFlowModelImplFactory
    ) {

        self.chooseDialogViewModelFactory = chooseDialogViewModelFactory
        self.importMediaFilesFlowModelFactory = importMediaFilesFlowModelFactory
        self.addMediaLibraryFolderFlowModelFactory = addMediaLibraryFolderFlowModelFactory
    }

    // MARK: - Methods

    public func create(
        targetFolderId: UUID?,
        delegate: AddMediaLibraryItemFlowModelDelegate
    ) -> AddMediaLibraryItemFlowModel {

        return AddMediaLibraryItemFlowModelImpl(
            targetFolderId: targetFolderId,
            delegate: delegate,
            chooseDialogViewModelFactory: chooseDialogViewModelFactory,
            importMediaFilesFlowModelFactory: importMediaFilesFlowModelFactory,
            addMediaLibraryFolderFlowModelFactory: addMediaLibraryFolderFlowModelFactory
        )
    }
}
