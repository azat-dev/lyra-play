//
//  DictionaryRepository.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 01.09.2022.
//

import Foundation

public enum DictionaryRepositoryError: Error {

    case itemNotFound
    case itemMustBeUnique
    case internalError(Error)
}

public enum DictionaryItemFilter: Hashable, Equatable {

    case lemma(String)
    case originalText(String)
}

public protocol DictionaryRepositoryInput {

    func putItem(_ item: DictionaryItem) async -> Result<DictionaryItem, DictionaryRepositoryError>

    func deleteItem(id: UUID) async -> Result<Void, DictionaryRepositoryError>
}

public protocol DictionaryRepositoryOutput {

    func getItem(id: UUID) async -> Result<DictionaryItem, DictionaryRepositoryError>

    func searchItems(with: [DictionaryItemFilter]) async -> Result<[DictionaryItem], DictionaryRepositoryError>

    func listItems() async -> Result<[DictionaryItem], DictionaryRepositoryError>
}

public protocol DictionaryRepository: DictionaryRepositoryOutput, DictionaryRepositoryInput {

}
