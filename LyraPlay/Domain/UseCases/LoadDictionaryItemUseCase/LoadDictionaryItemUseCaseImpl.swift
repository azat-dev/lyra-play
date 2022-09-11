//
//  LoadDictionaryItemUseCaseImpl.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 11.09.2022.
//

import Foundation

public final class LoadDictionaryItemUseCaseImpl: LoadDictionaryItemUseCase {

    // MARK: - Properties

    private let dictionaryRepository: DictionaryRepository

    // MARK: - Initializers

    public init(dictionaryRepository: DictionaryRepository) {

        self.dictionaryRepository = dictionaryRepository
    }
}

// MARK: - Input Methods

extension LoadDictionaryItemUseCaseImpl {

    public func load(itemId: UUID) async -> Result<DictionaryItem, LoadDictionaryItemUseCaseError> {

        let result = await dictionaryRepository.getItem(id: itemId)
        
        guard case .success(let item) = result else {
            
            return .failure(result.error!.map())
        }
        
        return .success(item)
    }
}

// MARK: - Output Methods

extension LoadDictionaryItemUseCaseImpl {

}

// MARK: - Error Mappings

fileprivate extension DictionaryRepositoryError {
    
    func map() -> LoadDictionaryItemUseCaseError {
        
        switch self {
            
        case .itemNotFound:
            return .itemNotFound
            
        case .internalError(let err):
            return .internalError(err)
            
        case .itemMustBeUnique:
            return .internalError(nil)
        }
    }
}
