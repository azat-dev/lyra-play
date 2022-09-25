//
//  EditDictionaryItemUseCase.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 12.09.2022.
//

import Foundation

public enum EditDictionaryItemUseCaseError: Error {

    case itemNotFound
    case internalError(Error?)
}

public protocol EditDictionaryItemUseCaseInput: AnyObject {

    func putItem(item: DictionaryItem) async -> Result<DictionaryItem, EditDictionaryItemUseCaseError>
}

public protocol EditDictionaryItemUseCaseOutput: AnyObject {

}

public protocol EditDictionaryItemUseCase: EditDictionaryItemUseCaseOutput, EditDictionaryItemUseCaseInput {

}