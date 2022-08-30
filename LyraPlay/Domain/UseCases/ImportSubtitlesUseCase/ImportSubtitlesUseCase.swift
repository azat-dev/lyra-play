//
//  ImportSubtitlesUseCase.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 30.08.2022.
//

import Foundation

public enum ImportSubtitlesUseCaseError: Error {
    
    case internalError(Error?)
    case wrongData
    case formatNotSupported
}

public protocol ImportSubtitlesUseCaseInput {
    
    func importFile(
        trackId: UUID,
        language: String,
        fileName: String,
        data: Data
    ) async -> Result<Void, ImportSubtitlesUseCaseError>
}

public protocol ImportSubtitlesUseCaseOutput {}

public protocol ImportSubtitlesUseCase: ImportSubtitlesUseCaseOutput, ImportSubtitlesUseCaseInput {}
