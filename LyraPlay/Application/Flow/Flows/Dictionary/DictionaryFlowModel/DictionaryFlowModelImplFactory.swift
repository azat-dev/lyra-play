//
//  DictionaryFlowModelImplFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 07.09.2022.
//

import Foundation

public final class DictionaryFlowModelImplFactory: DictionaryFlowModelFactory {

    // MARK: - Properties

    private let viewModelFactory: DictionaryListBrowserViewModelFactory
    private let addDictionaryItemFlowModelFactory: AddDictionaryItemFlowModelFactory

    // MARK: - Initializers

    public init(
        viewModelFactory: DictionaryListBrowserViewModelFactory,
        addDictionaryItemFlowModelFactory: AddDictionaryItemFlowModelFactory
    ) {

        self.viewModelFactory = viewModelFactory
        self.addDictionaryItemFlowModelFactory = addDictionaryItemFlowModelFactory
    }

    // MARK: - Methods

    public func create() -> DictionaryFlowModel {

        return DictionaryFlowModelImpl(
            viewModelFactory: viewModelFactory,
            addDictionaryItemFlowModelFactory: addDictionaryItemFlowModelFactory
        )
    }
}
