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

    // MARK: - Initializers

    public init(
        chooseDialogViewFactory: ChooseDialogViewFactory,
        importMediaFilesFlowPresenterFactory: ImportMediaFilesFlowPresenterFactory
    ) {

        self.chooseDialogViewFactory = chooseDialogViewFactory
        self.importMediaFilesFlowPresenterFactory = importMediaFilesFlowPresenterFactory
    }

    // MARK: - Methods

    public func create(for flowModel: AddMediaLibraryItemFlowModel) -> AddMediaLibraryItemFlowPresenter {

        return AddMediaLibraryItemFlowPresenterImpl(
            flowModel: flowModel,
            chooseDialogViewFactory: chooseDialogViewFactory,
            importMediaFilesFlowPresenterFactory: importMediaFilesFlowPresenterFactory
        )
    }
}