//
//  AddMediaLibraryItemFlowPresenterImplFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 19.09.2022.
//

import Foundation

public final class AddMediaLibraryItemFlowPresenterImplFactory: AddMediaLibraryItemFlowPresenterFactory {

    // MARK: - Properties

    private let chooseDialogViewFactory: ChooseDialogViewFactory
    private let importMediaFilesFlowPresenterFactory: ImportMediaFilesFlowPresenterFactory
    private let addMediaLibraryFolderFlowPresenterFactory: AddMediaLibraryFolderFlowPresenterFactory

    // MARK: - Initializers

    public init(
        chooseDialogViewFactory: ChooseDialogViewFactory,
        importMediaFilesFlowPresenterFactory: ImportMediaFilesFlowPresenterFactory,
        addMediaLibraryFolderFlowPresenterFactory: AddMediaLibraryFolderFlowPresenterFactory
    ) {

        self.chooseDialogViewFactory = chooseDialogViewFactory
        self.importMediaFilesFlowPresenterFactory = importMediaFilesFlowPresenterFactory
        self.addMediaLibraryFolderFlowPresenterFactory = addMediaLibraryFolderFlowPresenterFactory
    }

    // MARK: - Methods

    public func make(for flowModel: AddMediaLibraryItemFlowModel) -> AddMediaLibraryItemFlowPresenter {

        return AddMediaLibraryItemFlowPresenterImpl(
            flowModel: flowModel,
            chooseDialogViewFactory: chooseDialogViewFactory,
            importMediaFilesFlowPresenterFactory: importMediaFilesFlowPresenterFactory,
            addMediaLibraryFolderFlowPresenterFactory: addMediaLibraryFolderFlowPresenterFactory
        )
    }
}
