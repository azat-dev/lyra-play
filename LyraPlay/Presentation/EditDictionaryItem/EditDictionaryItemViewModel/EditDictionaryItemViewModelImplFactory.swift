//
//  EditDictionaryItemViewModelImplFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 12.09.2022.
//

import Foundation

public final class EditDictionaryItemViewModelImplFactory: EditDictionaryItemViewModelFactory {

    // MARK: - Properties

    private let delegate: EditDictionaryItemViewModelDelegate
    private let loadDictionaryItemUseCase: LoadDictionaryItemUseCase
    private let editDictionaryItemUseCase: EditDictionaryItemUseCase

    // MARK: - Initializers

    public init(
        delegate: EditDictionaryItemViewModelDelegate,
        loadDictionaryItemUseCase: LoadDictionaryItemUseCase,
        editDictionaryItemUseCase: EditDictionaryItemUseCase
    ) {

        self.delegate = delegate
        self.loadDictionaryItemUseCase = loadDictionaryItemUseCase
        self.editDictionaryItemUseCase = editDictionaryItemUseCase
    }

    // MARK: - Methods

    public func create(with params: EditDictionaryItemParams) -> EditDictionaryItemViewModel {

        return EditDictionaryItemViewModelImpl(
            params: params,
            delegate: delegate,
            loadDictionaryItemUseCase: loadDictionaryItemUseCase,
            editDictionaryItemUseCase: editDictionaryItemUseCase
        )
    }
}
