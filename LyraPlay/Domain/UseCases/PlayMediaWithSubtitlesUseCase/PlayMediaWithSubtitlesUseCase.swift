//
//  PlayMediaWithSubtitlesUseCase.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 31.08.2022.
//

import Foundation
import Combine

public enum PlayMediaWithSubtitlesUseCaseError: Error {

    case mediaFileNotFound
    case internalError(Error?)
    case noActiveMedia
}

public enum PlayMediaWithSubtitlesUseCaseState: Equatable {

    case initial
    case loading(session: PlayMediaWithSubtitlesSessionParams)
    case loadFailed(session: PlayMediaWithSubtitlesSessionParams)
    case loaded(session: PlayMediaWithSubtitlesSessionParams, subtitlesState: SubtitlesState?)
    case playing(session: PlayMediaWithSubtitlesSessionParams, subtitlesState: SubtitlesState?)
    case paused(session: PlayMediaWithSubtitlesSessionParams, subtitlesState: SubtitlesState?, time: TimeInterval)
    case stopped(session: PlayMediaWithSubtitlesSessionParams)
    case finished(session: PlayMediaWithSubtitlesSessionParams)
}

public protocol PlayMediaWithSubtitlesUseCaseInput {

    func prepare(params: PlayMediaWithSubtitlesSessionParams) async -> Result<Void, PlayMediaWithSubtitlesUseCaseError>

    func play() -> Result<Void, PlayMediaWithSubtitlesUseCaseError>

    func play(atTime: TimeInterval) -> Result<Void, PlayMediaWithSubtitlesUseCaseError>

    func pause() -> Result<Void, PlayMediaWithSubtitlesUseCaseError>

    func stop() -> Result<Void, PlayMediaWithSubtitlesUseCaseError>
    
    func togglePlay() -> Result<Void, PlayMediaWithSubtitlesUseCaseError>
}

public protocol PlayMediaWithSubtitlesUseCaseOutput {

    var state: CurrentValueSubject<PlayMediaWithSubtitlesUseCaseState, Never> { get }

    var willChangeSubtitlesPosition: PassthroughSubject<WillChangeSubtitlesPositionData, Never> { get }
}

public protocol PlayMediaWithSubtitlesUseCase: PlayMediaWithSubtitlesUseCaseOutput, PlayMediaWithSubtitlesUseCaseInput {

}
