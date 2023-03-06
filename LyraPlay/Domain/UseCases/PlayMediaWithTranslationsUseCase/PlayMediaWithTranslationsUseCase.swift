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
    case loading
    case loaded
    case loadFailed
    case playing
    case pronouncingTranslations
    case paused
    case stopped
    case finished
}

public enum PlayMediaWithTranslationsUseCaseState: Equatable {
    
    case noActiveSession
    case activeSession(
        PlayMediaWithTranslationsSession,
        PlayMediaWithTranslationsUseCasePlayerState
    )
}

// MARK: - Protocols

public protocol PlayMediaWithTranslationsUseCaseInput {
    
    func prepare(session: PlayMediaWithTranslationsSession) async -> Result<Void, PlayMediaWithTranslationsUseCaseError>
    
    func resume() -> Result<Void, PlayMediaWithTranslationsUseCaseError>
    
    func play(atTime: TimeInterval) -> Result<Void, PlayMediaWithTranslationsUseCaseError>
    
    func pause() -> Result<Void, PlayMediaWithTranslationsUseCaseError>
    
    func stop() -> Result<Void, PlayMediaWithTranslationsUseCaseError>
    
    func togglePlay() -> Result<Void, PlayMediaWithTranslationsUseCaseError>
    
    func set(currentTime: TimeInterval)
}

public protocol PlayMediaWithTranslationsUseCaseOutput {
    
    var subtitlesState: CurrentValueSubject<SubtitlesState?, Never> { get }
    
    var state: CurrentValueSubject<PlayMediaWithTranslationsUseCaseState, Never> { get }
    
    var pronounceTranslationsState: CurrentValueSubject<PronounceTranslationsUseCaseState, Never> { get }
    
    var currentTime: TimeInterval { get }
    
    var duration: TimeInterval { get }
}

public protocol PlayMediaWithTranslationsUseCase: PlayMediaWithTranslationsUseCaseOutput, PlayMediaWithTranslationsUseCaseInput {}
