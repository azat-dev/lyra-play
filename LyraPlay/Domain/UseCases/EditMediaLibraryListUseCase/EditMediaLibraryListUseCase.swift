//
//  EditMediaLibraryListUseCase.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 14.09.2022.
//

import Foundation

public enum EditMediaLibraryListUseCaseError: Error {

    case itemNotFound
    case nameMustBeUnique
    case internalError(Error?)
}

public protocol EditMediaLibraryListUseCaseInput: AnyObject {

    func deleteItem(id: UUID) async -> Result<Void, EditMediaLibraryListUseCaseError>
    
    func addFolder(data: NewMediaLibraryFolderData) async -> Result<MediaLibraryFolder, EditMediaLibraryListUseCaseError>
}

public protocol EditMediaLibraryListUseCaseOutput: AnyObject {}

public protocol EditMediaLibraryListUseCase: EditMediaLibraryListUseCaseOutput, EditMediaLibraryListUseCaseInput {}
