//
//  DictionaryFlowModelImpl.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 07.09.2022.
//

import Foundation

public final class DictionaryFlowModelImpl: DictionaryFlowModel {

    // MARK: - Properties

    private let viewModelFactory: DictionaryListBrowserViewModelFactory
    
    public lazy var listViewModel: DictionaryListBrowserViewModel  = {
        return viewModelFactory.create(delegate: self)
    } ()

    // MARK: - Initializers

    public init(viewModelFactory: DictionaryListBrowserViewModelFactory) {

        self.viewModelFactory = viewModelFactory
    }
}

// MARK: - Input Methods

extension DictionaryFlowModelImpl {

}

// MARK: - DictionaryListBrowserViewModelDelegate

extension DictionaryFlowModelImpl: DictionaryListBrowserViewModelDelegate {

    public func runCreationFlow() {
    }
}
