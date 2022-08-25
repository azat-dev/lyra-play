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

private extension BrowseListDictionaryItem {
    
    init(_ item: DictionaryItem) {
        
        id = item.id!
        originalText = item.originalText
        translatedText = item.translations.first?.text ?? ""
    }
}

public protocol BrowseDictionaryUseCase {

    func listItems() async -> Result<[BrowseListDictionaryItem], BrowseDictionaryUseCaseError>
}

// MARK: - Implementations

public final class BrowseDictionaryUseCaseImpl: BrowseDictionaryUseCase {

    // MARK: - Properties

    private let dictionaryRepository: DictionaryRepository

    // MARK: - Initializers

    public init(dictionaryRepository: DictionaryRepository) {

        self.dictionaryRepository = dictionaryRepository
    }

    // MARK: - Methods

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
