//
//  ManageSubtitlesUseCase.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 15.09.2022.
//

import Foundation

public enum ManageSubtitlesUseCaseError: Error {

    case itemNotFound
    case internalError(Error?)
}

public protocol ManageSubtitlesUseCaseInput: AnyObject {

    func deleteItem(mediaId: UUID, language: String) async -> Result<Void, ManageSubtitlesUseCaseError>
    
    func deleteAllFor(mediaId: UUID) async -> Result<Void, ManageSubtitlesUseCaseError>
}

public protocol ManageSubtitlesUseCaseOutput: AnyObject {

}

public protocol ManageSubtitlesUseCase: ManageSubtitlesUseCaseOutput, ManageSubtitlesUseCaseInput {

}
