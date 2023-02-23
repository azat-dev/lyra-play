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
    case playing(SubtitlesState?)
    case paused(subtitlesState: SubtitlesState?, time: TimeInterval)
    case stopped
    case finished(SubtitlesState)
}

public enum PlayMediaWithSubtitlesUseCaseLoadState: Equatable {

    case loading
    case loadFailed
    case loaded(Subtitles, PlayMediaWithTranslationsUseCasePlayerState)
}

public enum PlayMediaWithSubtitlesUseCaseState: Equatable {

    case noActiveSession
    case activeSession(PlayMediaWithSubtitlesSessionParams, PlayMediaWithTranslationsUseCaseLoadState)
}

public enum PlayMediaWithSubtitlesUseCasePlayerStateNew {

    case initial
    case playing
    case paused(time: TimeInterval)
    case stopped
    case finished
}

public enum PlayMediaWithSubtitlesUseCaseLoadStateNew {

    case loading
    case loadFailed
    case loaded(CurrentValueSubject<SubtitlesState?, Never>, PlayMediaWithSubtitlesUseCasePlayerStateNew)
}

public enum PlayMediaWithSubtitlesUseCaseStateNew {

    case noActiveSession
    case activeSession(PlayMediaWithSubtitlesSessionParams, PlayMediaWithSubtitlesUseCaseLoadStateNew)
}

// MARK: - Protocols

public protocol PlayMediaWithSubtitlesUseCaseInput: AnyObject {

    func prepare(params: PlayMediaWithSubtitlesSessionParams) async -> Result<Void, PlayMediaWithSubtitlesUseCaseError>

    func play() -> Result<Void, PlayMediaWithSubtitlesUseCaseError>

    func play(atTime: TimeInterval) -> Result<Void, PlayMediaWithSubtitlesUseCaseError>

    func pause() -> Result<Void, PlayMediaWithSubtitlesUseCaseError>

    func stop() -> Result<Void, PlayMediaWithSubtitlesUseCaseError>
    
    func togglePlay() -> Result<Void, PlayMediaWithSubtitlesUseCaseError>
}

public protocol PlayMediaWithSubtitlesUseCaseDelegate: AnyObject {
    
    func playMediaWithSubtitlesUseCaseWillChange(
        from: SubtitlesPosition?,
        to: SubtitlesPosition?,
        stop: inout Bool
    )
    
    func playMediaWithSubtitlesUseCaseDidChange(position: SubtitlesPosition?)
    
    func playMediaWithSubtitlesUseCaseDidFinish()
}

public protocol PlayMediaWithSubtitlesUseCaseOutputNew {

    var state: CurrentValueSubject<PlayMediaWithSubtitlesUseCaseStateNew, Never> { get }

    var delegate: PlayMediaWithSubtitlesUseCaseDelegate? { get set }
}

public protocol PlayMediaWithSubtitlesUseCaseNew: PlayMediaWithSubtitlesUseCaseOutputNew, PlayMediaWithSubtitlesUseCaseInput {

}

public protocol PlayMediaWithSubtitlesUseCaseOutput {

    var state: CurrentValueSubject<PlayMediaWithSubtitlesUseCaseState, Never> { get }

    var willChangeSubtitlesPosition: PassthroughSubject<WillChangeSubtitlesPositionData, Never> { get }
}

public protocol PlayMediaWithSubtitlesUseCase: PlayMediaWithSubtitlesUseCaseOutput, PlayMediaWithSubtitlesUseCaseInput {

}
