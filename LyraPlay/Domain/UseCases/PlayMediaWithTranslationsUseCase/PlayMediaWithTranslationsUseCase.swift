//
//  PlayMediaWithTranslationsUseCase.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 31.08.2022.
//

import Foundation
import Combine

public enum PlayMediaWithTranslationsUseCaseError: Error {
    
    case mediaFileNotFound
    case noActiveMedia
    case internalError(Error?)
    case taskCancelled
}

public enum PlayMediaWithTranslationsUseCaseState: Equatable {
    
    case initial
    case loading(session: PlayMediaWithTranslationsSession)
    case loadFailed(session: PlayMediaWithTranslationsSession)
    case loaded(session: PlayMediaWithTranslationsSession, subtitlesState: SubtitlesState?)
    case playing(session: PlayMediaWithTranslationsSession, subtitlesState: SubtitlesState?)
    case pronouncingTranslations(session: PlayMediaWithTranslationsSession, subtitlesState: SubtitlesState?, data: PronounceTranslationsUseCaseStateData)
    case paused(session: PlayMediaWithTranslationsSession, subtitlesState: SubtitlesState?, time: TimeInterval)
    case stopped(session: PlayMediaWithTranslationsSession)
    case finished(session: PlayMediaWithTranslationsSession)
}

public protocol PlayMediaWithTranslationsUseCaseInput {
    
    func prepare(session: PlayMediaWithTranslationsSession) async -> Result<Void, PlayMediaWithTranslationsUseCaseError>
    
    func play() -> Result<Void, PlayMediaWithTranslationsUseCaseError>
    
    func play(atTime: TimeInterval) -> Result<Void, PlayMediaWithTranslationsUseCaseError>
    
    func pause() -> Result<Void, PlayMediaWithTranslationsUseCaseError>
    
    func stop() -> Result<Void, PlayMediaWithTranslationsUseCaseError>
}

public protocol PlayMediaWithTranslationsUseCaseOutput {
    
    var state: PublisherWithSession<PlayMediaWithTranslationsUseCaseState, Never> { get }
}

public protocol PlayMediaWithTranslationsUseCase: PlayMediaWithTranslationsUseCaseOutput, PlayMediaWithTranslationsUseCaseInput {
    
}
