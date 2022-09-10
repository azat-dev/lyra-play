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

    // MARK: - Initializers

    public init(viewModelFactory: DictionaryListBrowserViewModelFactory) {

        self.viewModelFactory = viewModelFactory
    }

    // MARK: - Methods

    public func create() -> DictionaryFlowModel {

        return DictionaryFlowModelImpl(viewModelFactory: viewModelFactory)
    }
}