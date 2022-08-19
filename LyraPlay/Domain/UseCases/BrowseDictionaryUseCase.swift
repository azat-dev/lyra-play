//
//  BrowseDictionaryUseCase.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 19.08.2022.
//

import Foundation

// MARK: - Interfaces

public enum BrowseDictionaryUseCaseError: Error {

    case internalError(Error?)
    case itemNotFound
}

public struct BrowseListDictionaryItem: Equatable {

    public var id: UUID
    public var originalText: String
    public var translatedText: String

    public init(
        id: UUID,
        originalText: String,
        translatedText: String
    ) {

        self.id = id
        self.originalText = originalText
        self.translatedText = translatedText
    }
}

public protocol BrowseDictionaryUseCase {

    func listItems() async -> Result<[BrowseListDictionaryItem], BrowseDictionaryUseCaseError>
}

// MARK: - Implementations

public final class DefaultBrowseDictionaryUseCase: BrowseDictionaryUseCase {

    // MARK: - Properties

    private let dictionaryRepository: DictionaryRepository

    // MARK: - Initializers

    public init(dictionaryRepository: DictionaryRepository) {

        self.dictionaryRepository = dictionaryRepository
    }

    // MARK: - Methods

    public func listItems() async -> Result<[BrowseListDictionaryItem], BrowseDictionaryUseCaseError> {

        fatalError("Not implemented")
    }

    public func getItem() async -> Result<DictionaryItem, BrowseDictionaryUseCaseError> {

        fatalError("Not implemented")
    }
}
