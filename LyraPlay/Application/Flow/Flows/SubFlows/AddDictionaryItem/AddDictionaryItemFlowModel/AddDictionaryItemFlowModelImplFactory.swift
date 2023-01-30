//
//  AddDictionaryItemFlowModelImplFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 12.09.2022.
//

import Foundation

public final class AddDictionaryItemFlowModelImplFactory: AddDictionaryItemFlowModelFactory {

    // MARK: - Properties

    private let editDictionaryItemViewModelFactory: EditDictionaryItemViewModelFactory

    // MARK: - Initializers

    public init(editDictionaryItemViewModelFactory: EditDictionaryItemViewModelFactory) {

        self.editDictionaryItemViewModelFactory = editDictionaryItemViewModelFactory
    }

    // MARK: - Methods

    public func create(
        originalText: String?,
        delegate: AddDictionaryItemFlowModelDelegate
    ) -> AddDictionaryItemFlowModel {

        return AddDictionaryItemFlowModelImpl(
            originalText: originalText,
            delegate: delegate,
            editDictionaryItemViewModelFactory: editDictionaryItemViewModelFactory
        )
    }
}
