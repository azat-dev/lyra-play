//
//  ImportDictionaryArchiveUseCaseImpl.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 21.01.2023.
//

import Foundation

public final class ImportDictionaryArchiveUseCaseImpl: ImportDictionaryArchiveUseCase {
    
    // MARK: - Properties
    
    private let dictionaryRepository: DictionaryRepository
    private let dictionaryArchiveParser: DictionaryArchiveParser
    
    // MARK: - Initializers
    
    public init(
        dictionaryRepository: DictionaryRepository,
        dictionaryArchiveParser: DictionaryArchiveParser
    ) {
        
        self.dictionaryRepository = dictionaryRepository
        self.dictionaryArchiveParser = dictionaryArchiveParser
    }
}

// MARK: - Input Methods

extension ImportDictionaryArchiveUseCaseImpl {
    
    public func importArchive(data: Data) async -> Result<Void, ImportDictionaryArchiveUseCaseError> {
        
        let parseResult = await dictionaryArchiveParser.parse(data: data)
        
        guard case .success(let exportedItems) = parseResult else {
            return .failure(.wrongDataFormat)
        }
        
        let searchResult = await dictionaryRepository.searchItems(with: exportedItems.map { .originalText($0.original) })
        
        guard case .success(let foundItems) = searchResult else {
            return .failure(.internalError(nil))
        }
        
        let foundItemsByOriginalText = foundItems.reduce(into: [String: DictionaryItem]()) {
            partialResult, item in
            
            partialResult[item.originalText.lowercased()] = item
        }
        
        for item in exportedItems {
            
            var itemToSave: DictionaryItem
            let translations = item.translations.map {
                TranslationItem(id: UUID(), text: $0)
            }
            
            if let foundItem = foundItemsByOriginalText[item.original.lowercased()] {
                
                itemToSave = foundItem
                itemToSave.originalText = item.original
                itemToSave.lemma = item.original
                itemToSave.translations = translations
                
            } else {
                itemToSave = DictionaryItem(
                    originalText: item.original,
                    lemma: item.original,
                    language: "English",
                    translations: translations
                )
            }
            
            
            let putResult = await dictionaryRepository.putItem(itemToSave)
            
            guard case .success = putResult else {
                return .failure(.internalError(nil))
            }
        }
        
        return .success(())
    }
}

// MARK: Error Mappings

fileprivate extension DictionaryRepositoryError {
    
    func map() -> ImportDictionaryArchiveUseCaseError {
        
        switch self {
            
        case .itemNotFound:
            return .internalError(nil)
            
        case .itemMustBeUnique:
            return .internalError(nil)
            
        case .internalError(let error):
            return .internalError(error)
        }
    }
}
