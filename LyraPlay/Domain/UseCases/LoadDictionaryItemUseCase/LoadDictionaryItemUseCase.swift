//
//  LoadDictionaryItemUseCase.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 11.09.2022.
//

import Foundation

public enum LoadDictionaryItemUseCaseError: Error {

    case itemNotFound
    case internalError(Error?)
}

public protocol LoadDictionaryItemUseCaseInput: AnyObject {

    func load(itemId: UUID) async -> Result<DictionaryItem, LoadDictionaryItemUseCaseError>
}

public protocol LoadDictionaryItemUseCaseOutput: AnyObject {}

public protocol LoadDictionaryItemUseCase: LoadDictionaryItemUseCaseOutput, LoadDictionaryItemUseCaseInput {}
