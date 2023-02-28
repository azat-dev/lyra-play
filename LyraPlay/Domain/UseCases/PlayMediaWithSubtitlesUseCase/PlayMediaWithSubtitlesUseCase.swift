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

public enum PlayMediaWithSubtitlesUseCasePlayerState: Equatable {

    case initial
    case loading
    case loadFailed
    case loaded
    case playing
    case paused
    case stopped
    case finished
}


public enum PlayMediaWithSubtitlesUseCaseState: Equatable {

    case noActiveSession
    case activeSession(
        PlayMediaWithSubtitlesSessionParams,
        PlayMediaWithSubtitlesUseCasePlayerState
    )
}

// MARK: - Protocols

public protocol PlayMediaWithSubtitlesUseCaseInput: AnyObject {

    func prepare(params: PlayMediaWithSubtitlesSessionParams) async -> Result<Void, PlayMediaWithSubtitlesUseCaseError>

    func resume() -> Result<Void, PlayMediaWithSubtitlesUseCaseError>

    func play(atTime: TimeInterval) -> Result<Void, PlayMediaWithSubtitlesUseCaseError>

    func pause() -> Result<Void, PlayMediaWithSubtitlesUseCaseError>

    func stop() -> Result<Void, PlayMediaWithSubtitlesUseCaseError>
    
    func togglePlay() -> Result<Void, PlayMediaWithSubtitlesUseCaseError>
}

public protocol PlayMediaWithSubtitlesUseCaseDelegate: AnyObject {
    
    func playMediaWithSubtitlesUseCaseWillChange(
        from: SubtitlesPosition?,
        to: SubtitlesPosition?,
        interrupt: inout Bool
    )
    
    func playMediaWithSubtitlesUseCaseDidChange(position: SubtitlesPosition?)
    
    func playMediaWithSubtitlesUseCaseDidFinish()
}

public extension PlayMediaWithSubtitlesUseCaseDelegate {
    
    func playMediaWithSubtitlesUseCaseWillChange(
        from: SubtitlesPosition?,
        to: SubtitlesPosition?,
        interrupt: inout Bool
    ) {}
    
    func playMediaWithSubtitlesUseCaseDidChange(position: SubtitlesPosition?) {}
    
    func playMediaWithSubtitlesUseCaseDidFinish() {}
}

public protocol PlayMediaWithSubtitlesUseCaseOutput: AnyObject {

    var state: CurrentValueSubject<PlayMediaWithSubtitlesUseCaseState, Never> { get }
    
    var subtitlesState: CurrentValueSubject<SubtitlesState?, Never> { get }

    var delegate: PlayMediaWithSubtitlesUseCaseDelegate? { get set }
}

public protocol PlayMediaWithSubtitlesUseCase: PlayMediaWithSubtitlesUseCaseOutput, PlayMediaWithSubtitlesUseCaseInput {

}
