//
//  DictionaryRepository.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 19.07.22.
//

import Foundation

// MARK: - Interfaces

public struct DictionaryItemFilter: Hashable {
    
    public var lemma: String?
    
    public init(lemma: String) {
        
        self.lemma = lemma
    }
}

public enum DictionaryRepositoryError: Error {
    
    case itemNotFound
    case itemMustBeUnique
    case internalError(Error)
}

public protocol DictionaryRepository {
    
    func putItem(_ item: DictionaryItem) async -> Result<DictionaryItem, DictionaryRepositoryError>
    
    func getItem(id: UUID) async -> Result<DictionaryItem, DictionaryRepositoryError>
    
    func deleteItem(id: UUID) async -> Result<Void, DictionaryRepositoryError>
    
    func searchItems(with: [DictionaryItemFilter]) async -> Result<[DictionaryItem], DictionaryRepositoryError>
}
