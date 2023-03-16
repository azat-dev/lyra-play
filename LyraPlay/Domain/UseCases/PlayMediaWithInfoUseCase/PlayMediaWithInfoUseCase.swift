//
//  PlayMediaWithInfoUseCase.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 29.09.22.
//

import Foundation
import Combine

// MARK: - Enums

public enum PlayMediaWithInfoUseCaseError: Error {
    
    case mediaFileNotFound
    case noActiveMedia
    case taskCancelled
    case internalError(Error?)
}

public enum PlayMediaWithInfoUseCasePlayerState: Equatable {
    
    case initial
    case playing
    case pronouncingTranslations
    case paused
    case stopped
    case finished
}

public enum PlayMediaWithInfoUseCaseLoadState {
    
    case loading
    case loadFailed
    case loaded(
        CurrentValueSubject<PlayMediaWithInfoUseCasePlayerState, Never>,
        MediaInfo
    )
}

public enum PlayMediaWithInfoUseCaseState {
    
    case noActiveSession
    case activeSession(
        PlayMediaWithInfoSession,
        CurrentValueSubject<PlayMediaWithInfoUseCaseLoadState, Never>
    )
}

// MARK: - Protocols

public protocol PlayMediaWithInfoUseCaseInput: AnyObject {
    
    func prepare(session: PlayMediaWithInfoSession) async -> Result<Void, PlayMediaWithInfoUseCaseError>
    
    func resume() -> Result<Void, PlayMediaWithInfoUseCaseError>
    
    func play(atTime: TimeInterval) -> Result<Void, PlayMediaWithInfoUseCaseError>
    
    func pause() -> Result<Void, PlayMediaWithInfoUseCaseError>
    
    func stop() -> Result<Void, PlayMediaWithInfoUseCaseError>
    
    func togglePlay() -> Result<Void, PlayMediaWithInfoUseCaseError>
    
    func setTime(_ time: TimeInterval)
}

public protocol PlayMediaWithInfoUseCaseOutput: AnyObject {
    
    var state: CurrentValueSubject<PlayMediaWithInfoUseCaseState, Never> { get }
    
    var subtitlesState: CurrentValueSubject<SubtitlesState?, Never> { get }
    
    var pronounceTranslationsState: CurrentValueSubject<PronounceTranslationsUseCaseState, Never> { get }
    
    var currentTime: TimeInterval { get }

    var duration: TimeInterval { get }
}

public protocol PlayMediaWithInfoUseCase: PlayMediaWithInfoUseCaseOutput, PlayMediaWithInfoUseCaseInput {}
