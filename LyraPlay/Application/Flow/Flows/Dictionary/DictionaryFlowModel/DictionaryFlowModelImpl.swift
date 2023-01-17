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
    private let deleteDictionaryItemFlowModelFactory: DeleteDictionaryItemFlowModelFactory
    
    public lazy var listViewModel: DictionaryListBrowserViewModel  = {
        return viewModelFactory.create(delegate: self)
    } ()
    
    public var addDictionaryItemFlow = CurrentValueSubject<AddDictionaryItemFlowModel?, Never>(nil)
    public var deleteDictionaryItemFlow = CurrentValueSubject<DeleteDictionaryItemFlowModel?, Never>(nil)
    
    private var observers = Set<AnyCancellable>()

    // MARK: - Initializers

    public init(
        viewModelFactory: DictionaryListBrowserViewModelFactory,
        addDictionaryItemFlowModelFactory: AddDictionaryItemFlowModelFactory,
        deleteDictionaryItemFlowModelFactory: DeleteDictionaryItemFlowModelFactory
    ) {

        self.viewModelFactory = viewModelFactory
        self.addDictionaryItemFlowModelFactory = addDictionaryItemFlowModelFactory
        self.deleteDictionaryItemFlowModelFactory = deleteDictionaryItemFlowModelFactory
    }
    
    deinit {
        observers.removeAll()
    }
}

// MARK: - Helpers

extension DictionaryFlowModelImpl {

    private func reloadList() {
        
        Task {
            await listViewModel.load()
        }
    }
}

// MARK: - AddDictionaryItemFlowModelDelegate

extension DictionaryFlowModelImpl: AddDictionaryItemFlowModelDelegate {
    
    public func addDictionaryItemFlowModelDidFinish() {
    
        addDictionaryItemFlow.value = nil
        reloadList()
    }
}

extension DictionaryFlowModelImpl: DeleteDictionaryItemFlowDelegate {
    
    public func deleteDictionaryItemFlowDidFail() {
        
        deleteDictionaryItemFlow.value = nil
        reloadList()
    }
    
    public func deleteDictionaryItemFlowDidCancel() {
        
        deleteDictionaryItemFlow.value = nil
    }
    
    public func deleteDictionaryItemFlowDidFinish(deleteIds: [UUID]) {
        
        deleteDictionaryItemFlow.value = nil
        reloadList()
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
    
    public func runDeleteDictionaryItemFlow(itemId: UUID) {
        
        guard deleteDictionaryItemFlow.value == nil else {
            return
        }
        
        deleteDictionaryItemFlow.value = deleteDictionaryItemFlowModelFactory.create(
            itemId: itemId,
            delegate: self
        )
    }
    
    public func runExportDictionaryFlow() {
        
        fatalError()
    }
}
