//
//  EditDictionaryListUseCase.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 13.09.2022.
//

import Foundation

public enum EditDictionaryListUseCaseError: Error {

    case itemNotFound
    case internalError(Error?)
}

public protocol EditDictionaryListUseCaseInput: AnyObject {

    func deleteItem(itemId: UUID) async -> Result<Void, EditDictionaryListUseCaseError>
}

public protocol EditDictionaryListUseCaseOutput: AnyObject {}

public protocol EditDictionaryListUseCase: EditDictionaryListUseCaseOutput, EditDictionaryListUseCaseInput {}
