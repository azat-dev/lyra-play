//
//  PlaySubtitlesUseCase.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 09.08.2022.
//

import Foundation

// MARK: - Interfaces

public enum PlaySubtitlesUseCaseState: Equatable {

    case initial
    case playing(position: SubtitlesPosition?)
    case paused(position: SubtitlesPosition?)
    case stopped
    case finished
}

public struct SubtitlesPosition: Equatable, Comparable {

    public var sentenceIndex: Int
    public var timeMarkIndex: Int?

    public init(
        sentenceIndex: Int,
        timeMarkIndex: Int?
    ) {

        self.sentenceIndex = sentenceIndex
        self.timeMarkIndex = timeMarkIndex
    }

        public static func sentence(_ index: Int) -> Self {
        return .init(sentenceIndex: index, timeMarkIndex: nil)
    }
    
    public static func < (lhs: SubtitlesPosition, rhs: SubtitlesPosition) -> Bool {
        
        if lhs.sentenceIndex < rhs.sentenceIndex {
            return true
        }
        
        if lhs.sentenceIndex > rhs.sentenceIndex {
            return false
        }
        
        return (lhs.timeMarkIndex ?? -1) < (rhs.timeMarkIndex ?? -1)
    }
}

public protocol PlaySubtitlesUseCaseInput {

    func play(at time: TimeInterval) -> Void

    func pause() -> Void

    func stop() -> Void
}

public protocol PlaySubtitlesUseCaseOutput {

    var state: Observable<PlaySubtitlesUseCaseState> { get }
}

public protocol PlaySubtitlesUseCase: AnyObject, PlaySubtitlesUseCaseOutput, PlaySubtitlesUseCaseInput {
}

// MARK: - Implementations

public final class DefaultPlaySubtitlesUseCase: PlaySubtitlesUseCase {

    // MARK: - Properties

    private let subtitlesIterator: SubtitlesIterator
    private let scheduler: Scheduler

    public let state = Observable(PlaySubtitlesUseCaseState.initial)

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
        
        scheduler.execute(timeline: subtitlesIterator, from: time) { [weak self] time in
            
            guard let self = self else {
                return
            }
            
            let isLast = self.subtitlesIterator.getTimeOfNextEvent() == nil

            guard !isLast else {
                
                self.state.value = .finished
                return
            }
            
            self.state.value = .playing(position: self.subtitlesIterator.currentPosition)
        }
    }

    public func pause() -> Void {

        scheduler.pause()
        state.value = .paused(position: self.subtitlesIterator.currentPosition)
    }

    public func stop() -> Void {

        scheduler.stop()
        subtitlesIterator.beginNextExecution(from: 0)
        state.value = .stopped
    }
}
