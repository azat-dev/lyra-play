//
//  AddDictionaryItemFlowPresenterImplFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 12.09.2022.
//

import Foundation

public final class AddDictionaryItemFlowPresenterImplFactory: AddDictionaryItemFlowPresenterFactory {

    // MARK: - Properties

    private let editDictionaryItemViewFactory: EditDictionaryItemViewFactory

    // MARK: - Initializers

    public init(editDictionaryItemViewFactory: EditDictionaryItemViewFactory) {

        self.editDictionaryItemViewFactory = editDictionaryItemViewFactory
    }

    // MARK: - Methods

    public func create(for flowModel: AddDictionaryItemFlowModel) -> AddDictionaryItemFlowPresenter {

        return AddDictionaryItemFlowPresenterImpl(
            flowModel: flowModel,
            editDictionaryItemViewFactory: editDictionaryItemViewFactory
        )
    }
}
