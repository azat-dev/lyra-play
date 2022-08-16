//
//  PlaySubtitlesUseCase.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 09.08.2022.
//

import Foundation
import Combine

// MARK: - Interfaces

public enum PlaySubtitlesUseCaseState: Equatable {

    case initial
    case playing(position: SubtitlesPosition?)
    case playingWillChangePosition(from: SubtitlesPosition?, to: SubtitlesPosition?)
    case paused(position: SubtitlesPosition?)
    case stopped
    case finished
}

extension PlaySubtitlesUseCaseState {
    
    public var position: SubtitlesPosition? {

        switch self {

        case .initial, .stopped, .finished:
            return nil

        case .playing(let position), .paused(let position), .playingWillChangePosition(let position, _):
            return position
        }
    }
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

    func play() -> Void
    
    func play(atTime: TimeInterval) -> Void

    func pause() -> Void

    func stop() -> Void
}

public protocol PlaySubtitlesUseCaseOutput {

    var state: CurrentValueSubject<PlaySubtitlesUseCaseState, Never> { get }
}

public protocol PlaySubtitlesUseCase: AnyObject, PlaySubtitlesUseCaseOutput, PlaySubtitlesUseCaseInput {
}

// MARK: - Implementations

public final class DefaultPlaySubtitlesUseCase: PlaySubtitlesUseCase {

    // MARK: - Properties

    private let subtitlesIterator: SubtitlesIterator
    private let scheduler: Scheduler

    public let state = CurrentValueSubject<PlaySubtitlesUseCaseState, Never>(.initial)

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

    private func didChangePosition() {
        
        let isLast = subtitlesIterator.getTimeOfNextEvent() == nil

        guard !isLast else {
            
            state.value = .finished
            return
        }
        
        state.value = .playing(position: subtitlesIterator.currentPosition)
    }
    
    private func willChangePosition(fromTime: TimeInterval?) {
        
        let currentPosition = fromTime == nil ? nil : subtitlesIterator.currentPosition
        let nextPosition = subtitlesIterator.getNextPosition()
        
        if currentPosition == nextPosition {
            return
        }
        
        state.value = .playingWillChangePosition(
            from: currentPosition,
            to: nextPosition
        )
    }
    
    private func play(from fromTime: TimeInterval) {
        
        scheduler.execute(
            timeline: subtitlesIterator,
            from: fromTime,
            didChange: { [weak self] _ in self?.didChangePosition() },
            willChange: { [weak self] fromTime, _ in self?.willChangePosition(fromTime: fromTime) }
        )
    }
    
    public func play() -> Void {
        
        if scheduler.isActive {
            scheduler.resume()
            return
        }
        
        play(from: 0)
    }
    
    public func play(atTime time: TimeInterval) -> Void {
    
        scheduler.stop()
        play(from: time)
    }

    public func pause() -> Void {

        scheduler.pause()
        state.value = .paused(position: self.subtitlesIterator.currentPosition)
    }

    public func stop() -> Void {

        scheduler.stop()
        let _ = subtitlesIterator.beginNextExecution(from: 0)
        state.value = .stopped
    }
}
