//
//  EditMediaLibraryListUseCase.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 14.09.2022.
//

import Foundation

public enum EditMediaLibraryListUseCaseError: Error {

    case itemNotFound
    case internalError(Error?)
}

public protocol EditMediaLibraryListUseCaseInput: AnyObject {

    func deleteItem(id: UUID) async -> Result<Void, EditMediaLibraryListUseCaseError>
}

public protocol EditMediaLibraryListUseCaseOutput: AnyObject {}

public protocol EditMediaLibraryListUseCase: EditMediaLibraryListUseCaseOutput, EditMediaLibraryListUseCaseInput {}
