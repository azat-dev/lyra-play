//
//  BrowseDictionaryUseCaseImpl.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 30.08.2022.
//

import Foundation

public final class BrowseDictionaryUseCaseImpl: BrowseDictionaryUseCase {
    
    // MARK: - Properties
    
    private let dictionaryRepository: DictionaryRepository
    
    // MARK: - Initializers
    
    public init(dictionaryRepository: DictionaryRepository) {
        
        self.dictionaryRepository = dictionaryRepository
    }
}

// MARK: - Input Methods

extension BrowseDictionaryUseCaseImpl {
}

// MARK: - Output Methods

extension BrowseDictionaryUseCaseImpl {
    
    public func listItems() async -> Result<[BrowseListDictionaryItem], BrowseDictionaryUseCaseError> {
        
        let result = await dictionaryRepository.listItems()
        
        guard case .success(let items) = result else {
            return .failure(result.error!.map())
        }
        
        return .success(items.map(BrowseListDictionaryItem.init))
    }
}

// MARK: - Error Mappings

fileprivate extension DictionaryRepositoryError {
    
    func map() -> BrowseDictionaryUseCaseError {
        
        switch self {
            
        case .internalError(let error):
            return .internalError(error)
            
        case .itemNotFound:
            return .itemNotFound
            
        case .itemMustBeUnique:
            return .internalError(nil)
        }
    }
}

