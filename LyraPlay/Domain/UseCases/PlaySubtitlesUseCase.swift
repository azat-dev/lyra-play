//
//  PlaySubtitlesUseCase.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 01.08.2022.
//

import Foundation

// MARK: - Interfaces

public enum SubtitlesPlayingState {

    case initial
    case playing
    case paused
    case stopped
    case finished
}

public struct SubtitlesPosition: Equatable {

    public var sentenceIndex: Int
    public var timeMarkIndex: Int?

    public init(
        sentenceIndex: Int,
        timeMarkIndex: Int?
    ) {

        self.sentenceIndex = sentenceIndex
        self.timeMarkIndex = timeMarkIndex
    }
}

public struct CurrentSubtitlesState {

    public var state: SubtitlesPlayingState
    public var position: SubtitlesPosition?

    public init(
        state: SubtitlesPlayingState,
        position: SubtitlesPosition?
    ) {

        self.state = state
        self.position = position
    }
}

public protocol PlaySubtitlesUseCaseInput {

    func play(at time: TimeInterval) -> Void

    func pause() -> Void

    func stop() -> Void
}

public protocol PlaySubtitlesUseCaseOutput {

    var state: Observable<CurrentSubtitlesState> { get }
}

public protocol PlaySubtitlesUseCase: PlaySubtitlesUseCaseOutput, PlaySubtitlesUseCaseInput {
}

// MARK: - Implementations

public final class DefaultPlaySubtitlesUseCase: PlaySubtitlesUseCase {

    // MARK: - Properties

    private let subtitlesIterator: SubtitlesIterator
    private let scheduler: Scheduler

    public let state: Observable<CurrentSubtitlesState> = Observable(
        .init(
            state: .initial,
            position: nil
        )
    )

    // MARK: - Initializers

    public init(
        subtitlesIterator: SubtitlesIterator,
        scheduler: Scheduler
    ) {

        self.subtitlesIterator = subtitlesIterator
        self.scheduler = scheduler
    }
}

// MARK: - Input methods

extension DefaultPlaySubtitlesUseCase {
    
    public func play(at time: TimeInterval) -> Void {

        scheduler.stop()
        
        scheduler.start(at: time) { [weak self] time in
            
            guard let self = self else {
                return
            }
            
            let isLast = self.subtitlesIterator.getNext() == nil
            
            self.state.value = .init(
                state: isLast ? .finished : .playing,
                position: self.subtitlesIterator.currentPosition
            )
        }
    }

    public func pause() -> Void {

        scheduler.pause()
    }

    public func stop() -> Void {

        scheduler.stop()
        let _ = subtitlesIterator.move(at: 0)
        state.value = .init(state: .stopped, position: nil)
    }
}
