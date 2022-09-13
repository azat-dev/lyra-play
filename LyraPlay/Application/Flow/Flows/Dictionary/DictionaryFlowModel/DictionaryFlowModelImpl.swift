//
//  DictionaryFlowModelImpl.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 07.09.2022.
//

import Foundation
import Combine

public final class DictionaryFlowModelImpl: DictionaryFlowModel {

    // MARK: - Properties

    private let viewModelFactory: DictionaryListBrowserViewModelFactory
    private let addDictionaryItemFlowModelFactory: AddDictionaryItemFlowModelFactory
    
    public lazy var listViewModel: DictionaryListBrowserViewModel  = {
        return viewModelFactory.create(delegate: self)
    } ()
    
    public var addDictionaryItemFlow = CurrentValueSubject<AddDictionaryItemFlowModel?, Never>(nil)
    
    private var observers = Set<AnyCancellable>()

    // MARK: - Initializers

    public init(
        viewModelFactory: DictionaryListBrowserViewModelFactory,
        addDictionaryItemFlowModelFactory: AddDictionaryItemFlowModelFactory
    ) {

        self.viewModelFactory = viewModelFactory
        self.addDictionaryItemFlowModelFactory = addDictionaryItemFlowModelFactory
    }
    
    deinit {
        observers.removeAll()
    }
}

// MARK: - Input Methods

extension DictionaryFlowModelImpl {

}

// MARK: - AddDictionaryItemFlowModelDelegate

extension DictionaryFlowModelImpl: AddDictionaryItemFlowModelDelegate {
    
    public func addDictionaryItemFlowModelDidFinish() {
    
        addDictionaryItemFlow.value = nil
        
        Task {
            await listViewModel.load()
        }
    }
}

// MARK: - DictionaryListBrowserViewModelDelegate

extension DictionaryFlowModelImpl: DictionaryListBrowserViewModelDelegate {

    public func runCreationFlow() {

        guard addDictionaryItemFlow.value == nil else {
            return
        }
        
        addDictionaryItemFlow.value = addDictionaryItemFlowModelFactory.create(
            originalText: "",
            delegate: self
        )
    }
}
