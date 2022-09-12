//
//  EditDictionaryItemUseCaseImpl.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 12.09.2022.
//

import Foundation

public final class EditDictionaryItemUseCaseImpl: EditDictionaryItemUseCase {

    // MARK: - Properties

    private let dictionaryRepository: DictionaryRepository
    private let lemmatizer: Lemmatizer

    // MARK: - Initializers

    public init(
        dictionaryRepository: DictionaryRepository,
        lemmatizer: Lemmatizer
    ) {

        self.dictionaryRepository = dictionaryRepository
        self.lemmatizer = lemmatizer
    }
}

// MARK: - Input Methods

extension EditDictionaryItemUseCaseImpl {

    public func putItem(item: DictionaryItem) async -> Result<DictionaryItem, EditDictionaryItemUseCaseError> {

        var itemWithLemma = item
        itemWithLemma.lemma = lemmatizer.lemmatize(text: item.originalText).map { $0.lemma }.joined(separator: " ")
        
        let result = await dictionaryRepository.putItem(itemWithLemma)
        
        guard case .success(let savedItem) = result else {
            return .failure(result.error!.map())
        }
        
        return .success(savedItem)
    }
}

// MARK: - Output Methods

extension EditDictionaryItemUseCaseImpl {

}

// MARK: Error Mappings

fileprivate extension DictionaryRepositoryError {

    func map() -> EditDictionaryItemUseCaseError {

        switch self {

            case .itemNotFound:
                return .itemNotFound

            case .itemMustBeUnique:
                return .internalError(nil)

            case .internalError(let error):
                return .internalError(error)
        }
    }
}
