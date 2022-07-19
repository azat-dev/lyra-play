//
//  DictionaryRepository.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 19.07.22.
//

import Foundation

// MARK: - Interfaces

public struct DictionaryItem {

    public var id: UUID?
    public var originalText: String
    public var language: String
    
    public init(id: UUID? = nil, originalText: String, language: String) {
        
        self.id = id
        self.originalText = originalText
        self.language = language
    }
}

public enum DictionaryRepositoryError: Error {
    
    case itemNotFound
    case internalError(Error)
}

public protocol DictionaryRepository {
    
    func putItem(_ item: DictionaryItem) async -> Result<DictionaryItem, DictionaryRepositoryError>
    
    func getItem(id: UUID) async -> Result<DictionaryItem, DictionaryRepositoryError>
    
    func deleteItem(id: UUID) async -> Result<Void, DictionaryRepositoryError>
}
