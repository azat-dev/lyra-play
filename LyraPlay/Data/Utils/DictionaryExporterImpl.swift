//
//  DictionaryExporterImpl.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 17.01.23.
//

import Foundation

public class DictionaryExporterImpl: DictionaryExporter {
    
    // MARK: - Initializers
    
    public init() {}
    
    // MARK: - Methods
    
    public func export(repository: DictionaryRepositoryOutputList) async -> Result<[ExportedDictionaryItem], Error> {
        
        let resultItems = await repository.listItems()
        
        guard case .success(let items) = resultItems else {
            
            return .failure(NSError(domain: "InternalError", code: 0))
        }
        
        return .success(items.map(ExportedDictionaryItem.init))
    }
}

internal extension ExportedDictionaryItem {
    
    init(_ dictionaryItem: DictionaryItem) {
        
        self.init(
            original: dictionaryItem.originalText,
            translations: dictionaryItem.translations.map { $0.text }
        )
    }
}
