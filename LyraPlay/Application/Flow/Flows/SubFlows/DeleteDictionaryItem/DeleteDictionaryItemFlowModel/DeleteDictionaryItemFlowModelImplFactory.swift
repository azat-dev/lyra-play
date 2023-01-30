//
//  DeleteDictionaryItemFlowModelImplFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 13.09.2022.
//

import Foundation

public final class DeleteDictionaryItemFlowModelImplFactory: DeleteDictionaryItemFlowModelFactory {

    // MARK: - Properties

    private let editDictionaryListUseCaseFactory: EditDictionaryListUseCaseFactory

    // MARK: - Initializers

    public init(editDictionaryListUseCaseFactory: EditDictionaryListUseCaseFactory) {

        self.editDictionaryListUseCaseFactory = editDictionaryListUseCaseFactory
    }

    // MARK: - Methods

    public func create(
        itemId: UUID,
        delegate: DeleteDictionaryItemFlowDelegate
    ) -> DeleteDictionaryItemFlowModel {

        return DeleteDictionaryItemFlowModelImpl(
            itemId: itemId,
            delegate: delegate,
            editDictionaryListUseCaseFactory: editDictionaryListUseCaseFactory
        )
    }
}
