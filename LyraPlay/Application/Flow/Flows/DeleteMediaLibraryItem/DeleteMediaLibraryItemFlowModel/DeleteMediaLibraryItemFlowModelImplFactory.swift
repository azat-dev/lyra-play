//
//  DeleteMediaLibraryItemFlowModelImplFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 15.09.2022.
//

import Foundation

public final class DeleteMediaLibraryItemFlowModelImplFactory: DeleteMediaLibraryItemFlowModelFactory {

    // MARK: - Properties

    private let editMediaLibraryListUseCaseFactory: EditMediaLibraryListUseCaseFactory
    private let confirmDialogViewModelFactory: ConfirmDialogViewModelFactory

    // MARK: - Initializers

    public init(
        editMediaLibraryListUseCaseFactory: EditMediaLibraryListUseCaseFactory,
        confirmDialogViewModelFactory: ConfirmDialogViewModelFactory
    ) {

        self.editMediaLibraryListUseCaseFactory = editMediaLibraryListUseCaseFactory
        self.confirmDialogViewModelFactory = confirmDialogViewModelFactory
    }

    // MARK: - Methods

    public func create(
        itemId: UUID,
        delegate: DeleteMediaLibraryItemFlowDelegate
    ) -> DeleteMediaLibraryItemFlowModel {

        return DeleteMediaLibraryItemFlowModelImpl(
            itemId: itemId,
            delegate: delegate,
            editMediaLibraryListUseCaseFactory: editMediaLibraryListUseCaseFactory,
            confirmDialogViewModelFactory: confirmDialogViewModelFactory
        )
    }
}
