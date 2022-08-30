//
//  BrowseDictionaryUseCase.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 30.08.2022.
//

import Foundation

public enum BrowseDictionaryUseCaseError: Error {

    case internalError(Error?)
    case itemNotFound
}

public protocol BrowseDictionaryUseCaseInput {}

public protocol BrowseDictionaryUseCaseOutput {

    func listItems() async -> Result<[BrowseListDictionaryItem], BrowseDictionaryUseCaseError>
}

public protocol BrowseDictionaryUseCase: BrowseDictionaryUseCaseOutput, BrowseDictionaryUseCaseInput {}
