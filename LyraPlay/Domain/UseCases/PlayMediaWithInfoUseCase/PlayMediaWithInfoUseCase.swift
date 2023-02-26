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

public enum PlayMediaWithInfoUseCaseLoadState: Equatable {
    
    case loading
    case loadFailed
    case loaded(PlayMediaWithInfoUseCasePlayerState, SubtitlesState?, MediaInfo)
}

public enum PlayMediaWithInfoUseCaseState: Equatable {
    
    case noActiveSession
    case activeSession(PlayMediaWithInfoSession, PlayMediaWithInfoUseCaseLoadState)
}

// MARK: - Protocols

public protocol PlayMediaWithInfoUseCaseInput: AnyObject {
    
    func prepare(session: PlayMediaWithInfoSession) async -> Result<Void, PlayMediaWithInfoUseCaseError>
    
    func play() -> Result<Void, PlayMediaWithInfoUseCaseError>
    
    func play(atTime: TimeInterval) -> Result<Void, PlayMediaWithInfoUseCaseError>
    
    func pause() -> Result<Void, PlayMediaWithInfoUseCaseError>
    
    func stop() -> Result<Void, PlayMediaWithInfoUseCaseError>
    
    func togglePlay() -> Result<Void, PlayMediaWithInfoUseCaseError>
}

public protocol PlayMediaWithInfoUseCaseOutput: AnyObject {
    
    var state: PublisherWithSession<PlayMediaWithInfoUseCaseState, Never> { get }
}

public protocol PlayMediaWithInfoUseCase: PlayMediaWithInfoUseCaseOutput, PlayMediaWithInfoUseCaseInput {}
