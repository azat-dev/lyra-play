//
//  LoadSubtitlesUseCase.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 30.08.2022.
//

import Foundation

public enum LoadSubtitlesUseCaseError: Error {

    case itemNotFound
    case internalError(Error?)
}

public protocol LoadSubtitlesUseCaseInput {

    func load(for: UUID, language: String) async -> Result<Subtitles, LoadSubtitlesUseCaseError>
}

public protocol LoadSubtitlesUseCaseOutput {}

public protocol LoadSubtitlesUseCase: LoadSubtitlesUseCaseOutput, LoadSubtitlesUseCaseInput {}
