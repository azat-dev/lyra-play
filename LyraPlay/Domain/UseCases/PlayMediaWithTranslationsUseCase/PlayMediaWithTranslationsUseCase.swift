//
//  PlayMediaWithTranslationsUseCase.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 31.08.2022.
//

import Foundation
import Combine

// MARK: - Enums

public enum PlayMediaWithTranslationsUseCaseError: Error {
    
    case mediaFileNotFound
    case noActiveMedia
    case internalError(Error?)
    case taskCancelled
}

public enum PlayMediaWithTranslationsUseCasePlayerState: Equatable {
    
    case initial
    case playing
    case pronouncingTranslations(data: PronounceTranslationsUseCaseStateData)
    case paused(time: TimeInterval)
    case stopped
    case finished
}

public enum PlayMediaWithTranslationsUseCaseLoadState: Equatable {
    
    case loading
    case loadFailed
    case loaded(PlayMediaWithTranslationsUseCasePlayerState, SubtitlesState?)
}

public enum PlayMediaWithTranslationsUseCaseState: Equatable {
    
    case noActiveSession
    case activeSession(PlayMediaWithTranslationsSession, PlayMediaWithTranslationsUseCaseLoadState)
}

// MARK: - Protocols

public protocol PlayMediaWithTranslationsUseCaseInput {
    
    func prepare(session: PlayMediaWithTranslationsSession) async -> Result<Void, PlayMediaWithTranslationsUseCaseError>
    
    func play() -> Result<Void, PlayMediaWithTranslationsUseCaseError>
    
    func play(atTime: TimeInterval) -> Result<Void, PlayMediaWithTranslationsUseCaseError>
    
    func pause() -> Result<Void, PlayMediaWithTranslationsUseCaseError>
    
    func stop() -> Result<Void, PlayMediaWithTranslationsUseCaseError>
    
    func togglePlay() -> Result<Void, PlayMediaWithTranslationsUseCaseError>
}

public protocol PlayMediaWithTranslationsUseCaseOutput {
    
    var state: PublisherWithSession<PlayMediaWithTranslationsUseCaseState, Never> { get }
}

public protocol PlayMediaWithTranslationsUseCase: PlayMediaWithTranslationsUseCaseOutput, PlayMediaWithTranslationsUseCaseInput {}
