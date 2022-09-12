//
//  AddDictionaryItemFlowModelImpl.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 12.09.2022.
//

import Foundation
import Combine

public final class AddDictionaryItemFlowModelImpl: AddDictionaryItemFlowModel {

    // MARK: - Properties

    private let originalText: String?
    private let delegate: AddDictionaryItemFlowModelDelegate
    private let editDictionaryItemViewModelFactory: EditDictionaryItemViewModelFactory
    
    public var editDictionaryItemViewModel = CurrentValueSubject<EditDictionaryItemViewModel?, Never>(nil)

    // MARK: - Initializers

    public init(
        originalText: String?,
        delegate: AddDictionaryItemFlowModelDelegate,
        editDictionaryItemViewModelFactory: EditDictionaryItemViewModelFactory
    ) {

        self.originalText = originalText
        self.delegate = delegate
        self.editDictionaryItemViewModelFactory = editDictionaryItemViewModelFactory
        
        editDictionaryItemViewModel.value = editDictionaryItemViewModelFactory.create(with: .newItem(originalText: originalText ?? ""))
    }
}

// MARK: - Input Methods

extension AddDictionaryItemFlowModelImpl {

}

// MARK: - Output Methods

extension AddDictionaryItemFlowModelImpl {

}
