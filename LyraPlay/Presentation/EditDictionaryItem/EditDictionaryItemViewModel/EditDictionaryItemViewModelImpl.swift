//
//  EditDictionaryItemViewModelImpl.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 12.09.2022.
//

import Foundation
import Combine

public final class EditDictionaryItemViewModelImpl: EditDictionaryItemViewModel {

    // MARK: - Properties

    private let params: EditDictionaryItemParams
    private let delegate: EditDictionaryItemViewModelDelegate
    private let loadDictionaryItemUseCase: LoadDictionaryItemUseCase
    private let editDictionaryItemUseCase: EditDictionaryItemUseCase
    
    public var state = CurrentValueSubject<EditDictionaryItemViewModelState, Never>(.loading)

    // MARK: - Initializers

    public init(
        params: EditDictionaryItemParams,
        delegate: EditDictionaryItemViewModelDelegate,
        loadDictionaryItemUseCase: LoadDictionaryItemUseCase,
        editDictionaryItemUseCase: EditDictionaryItemUseCase
    ) {

        self.params = params
        self.delegate = delegate
        self.loadDictionaryItemUseCase = loadDictionaryItemUseCase
        self.editDictionaryItemUseCase = editDictionaryItemUseCase
    }
}

// MARK: - Input Methods

extension EditDictionaryItemViewModelImpl {

    public func cancel() {

        fatalError()
    }

    public func save() {

        fatalError()
    }

    public func setOriginalText(value: String) {

        fatalError()
    }

    public func setTranslationText(value: String) {

        fatalError()
    }
}

// MARK: - Output Methods

extension EditDictionaryItemViewModelImpl {

}
