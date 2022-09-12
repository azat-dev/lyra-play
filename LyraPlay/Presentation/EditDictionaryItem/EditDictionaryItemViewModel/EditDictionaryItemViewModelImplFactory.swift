//
//  EditDictionaryItemViewModelImplFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 12.09.2022.
//

import Foundation

public final class EditDictionaryItemViewModelImplFactory: EditDictionaryItemViewModelFactory {

    // MARK: - Properties

    private let loadDictionaryItemUseCaseFactory: LoadDictionaryItemUseCaseFactory
    private let editDictionaryItemUseCaseFactory: EditDictionaryItemUseCaseFactory

    // MARK: - Initializers

    public init(
        loadDictionaryItemUseCaseFactory: LoadDictionaryItemUseCaseFactory,
        editDictionaryItemUseCaseFactory: EditDictionaryItemUseCaseFactory
    ) {

        self.loadDictionaryItemUseCaseFactory = loadDictionaryItemUseCaseFactory
        self.editDictionaryItemUseCaseFactory = editDictionaryItemUseCaseFactory
    }

    // MARK: - Methods

    public func create(
        with params: EditDictionaryItemParams,
        delegate: EditDictionaryItemViewModelDelegate
    ) -> EditDictionaryItemViewModel {

        return EditDictionaryItemViewModelImpl(
            params: params,
            delegate: delegate,
            loadDictionaryItemUseCase: loadDictionaryItemUseCaseFactory.create(),
            editDictionaryItemUseCase: editDictionaryItemUseCaseFactory.create()
        )
    }
}
