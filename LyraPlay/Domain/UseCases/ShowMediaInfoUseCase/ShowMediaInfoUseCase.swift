//
//  ShowMediaInfoUseCase.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 01.09.2022.
//

import Foundation

public enum ShowMediaInfoUseCaseError: Error {

    case trackNotFound
    case internalError(Error?)
}

public protocol ShowMediaInfoUseCaseInput {

}

public protocol ShowMediaInfoUseCaseOutput {

    func fetchInfo(trackId: UUID) async -> Result<MediaInfo, ShowMediaInfoUseCaseError>
}

public protocol ShowMediaInfoUseCase: ShowMediaInfoUseCaseOutput, ShowMediaInfoUseCaseInput {

}