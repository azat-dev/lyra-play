//
//  LoadTrackUseCase.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 30.08.2022.
//

import Foundation

public enum LoadTrackUseCaseError: Error {

    case trackNotFound
    case internalError(Error?)
}

public protocol LoadTrackUseCaseInput {

    func load(trackId: UUID) async -> Result<Data, LoadTrackUseCaseError>
}

public protocol LoadTrackUseCaseOutput {}

public protocol LoadTrackUseCase: LoadTrackUseCaseOutput, LoadTrackUseCaseInput {}
