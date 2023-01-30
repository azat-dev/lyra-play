//
//  DeleteMediaLibraryItemFlowPresenterImplFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 15.09.2022.
//

import Foundation

public final class DeleteMediaLibraryItemFlowPresenterImplFactory: DeleteMediaLibraryItemFlowPresenterFactory {

    // MARK: - Properties

    private let confirmDialogViewFactory: ConfirmDialogViewFactory

    // MARK: - Initializers

    public init(confirmDialogViewFactory: ConfirmDialogViewFactory) {

        self.confirmDialogViewFactory = confirmDialogViewFactory
    }

    // MARK: - Methods

    public func create(for flowModel: DeleteMediaLibraryItemFlowModel) -> DeleteMediaLibraryItemFlowPresenter {

        return DeleteMediaLibraryItemFlowPresenterImpl(
            flowModel: flowModel,
            confirmDialogViewFactory: confirmDialogViewFactory
        )
    }
}
