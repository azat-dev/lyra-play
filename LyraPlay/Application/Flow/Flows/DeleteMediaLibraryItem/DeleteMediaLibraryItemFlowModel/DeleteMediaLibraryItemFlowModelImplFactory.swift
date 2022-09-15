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

    // MARK: - Initializers

    public init(editMediaLibraryListUseCaseFactory: EditMediaLibraryListUseCaseFactory) {

        self.editMediaLibraryListUseCaseFactory = editMediaLibraryListUseCaseFactory
    }

    // MARK: - Methods

    public func create(
        itemId: UUID,
        delegate: DeleteMediaLibraryItemFlowDelegate
    ) -> DeleteMediaLibraryItemFlowModel {

        return DeleteMediaLibraryItemFlowModelImpl(
            itemId: itemId,
            delegate: delegate,
            editMediaLibraryListUseCaseFactory: editMediaLibraryListUseCaseFactory
        )
    }
}
