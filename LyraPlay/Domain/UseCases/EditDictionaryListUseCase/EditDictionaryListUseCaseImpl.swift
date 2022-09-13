//
//  EditDictionaryListUseCaseImpl.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 13.09.2022.
//

import Foundation

public final class EditDictionaryListUseCaseImpl: EditDictionaryListUseCase {

    // MARK: - Properties

    private let dictionaryRepository: DictionaryRepository

    // MARK: - Initializers

    public init(dictionaryRepository: DictionaryRepository) {

        self.dictionaryRepository = dictionaryRepository
    }
}

// MARK: - Input Methods

extension EditDictionaryListUseCaseImpl {

    public func deleteItem(itemId: UUID) async -> Result<Void, EditDictionaryListUseCaseError> {

        fatalError()
    }
}

// MARK: Error Mappings

fileprivate extension DictionaryRepositoryError {

    func map() -> EditDictionaryListUseCaseError {

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
