//
//  AddMediaLibraryFolderFlowPresenterImplFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 20.09.2022.
//

import Foundation

public final class AddMediaLibraryFolderFlowPresenterImplFactory: AddMediaLibraryFolderFlowPresenterFactory {

    // MARK: - Properties

    private let promptFolderNameViewFactory: PromptDialogViewFactory

    // MARK: - Initializers

    public init(promptFolderNameViewFactory: PromptDialogViewFactory) {

        self.promptFolderNameViewFactory = promptFolderNameViewFactory
    }

    // MARK: - Methods

    public func create(for flowModel: AddMediaLibraryFolderFlowModel) -> AddMediaLibraryFolderFlowPresenter {

        return AddMediaLibraryFolderFlowPresenterImpl(
            flowModel: flowModel,
            promptFolderNameViewFactory: promptFolderNameViewFactory
        )
    }
}