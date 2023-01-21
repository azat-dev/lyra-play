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
        fatalError()
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
