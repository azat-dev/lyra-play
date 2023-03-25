//
//  DictionaryRepository.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 01.09.2022.
//

import Foundation
import Combine

public enum DictionaryRepositoryError: Error {
    
    case itemNotFound
    case itemMustBeUnique
    case internalError(Error)
}

public enum DictionaryItemFilter: Hashable, Equatable {
    
    case lemma(String)
    case originalText(String)
}

public protocol DictionaryRepositoryInput {
    
    func putItem(_ item: DictionaryItem) async -> Result<DictionaryItem, DictionaryRepositoryError>
    
    func deleteItem(id: UUID) async -> Result<Void, DictionaryRepositoryError>
}

public protocol DictionaryRepositoryOutputList {
    
    func listItems() async -> Result<[DictionaryItem], DictionaryRepositoryError>
}

public enum DictionaryRepositoryChange {
    
    case didAddItem(DictionaryItem)
    case didChangeItem(from: DictionaryItem, to: DictionaryItem)
    case didDeleteItem(DictionaryItem)
}

public protocol DictionaryRepositoryOutputListenForChanges {
    
    var changes: PassthroughSubject<DictionaryRepositoryChange, Never> { get }
}

public protocol DictionaryRepositoryOutputGet {
    
    func getItem(id: UUID) async -> Result<DictionaryItem, DictionaryRepositoryError>
}

public protocol DictionaryRepositoryOutputSearch {
    
    func searchItems(with: [DictionaryItemFilter]) async -> Result<[DictionaryItem], DictionaryRepositoryError>
}

public protocol DictionaryRepositoryOutput: DictionaryRepositoryOutputList, DictionaryRepositoryOutputGet, DictionaryRepositoryOutputSearch, DictionaryRepositoryOutputListenForChanges {}

public protocol DictionaryRepository: DictionaryRepositoryOutput, DictionaryRepositoryInput {
    
}
