//
//  PlaySubtitlesUseCaseImpl.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 31.08.2022.
//

import Foundation
import Combine

public protocol PlaySubtitlesUseCaseDelegate {
    
    func playSubtitlesUseCaseWillChange(
        from currentPosition: SubtitlesPosition?,
        to nextPosition: SubtitlesPosition?,
        stop: inout Bool
    )
    
    func playSubtitlesUseCaseDidChangePosition()
}

public final class PlaySubtitlesUseCaseImpl: PlaySubtitlesUseCase {

    // MARK: - Properties

    private let subtitlesIterator: SubtitlesIterator
    private let scheduler: Scheduler
    public var state =  CurrentValueSubject<PlaySubtitlesUseCaseState, Never>(.initial)
    public var willChangePosition = PassthroughSubject<WillChangeSubtitlesPositionData, Never>()

    // MARK: - Initializers

    public init(
        subtitlesIterator: SubtitlesIterator,
        scheduler: Scheduler
    ) {

        self.subtitlesIterator = subtitlesIterator
        self.scheduler = scheduler
    }
}

// MARK: - Input Methods

extension PlaySubtitlesUseCaseImpl {
    
    private func didChangePosition() {
        
        let isLast = subtitlesIterator.getTimeOfNextEvent() == nil
        
        if isLast {
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
        
        willChangePosition.send(
            .init(
                from: currentPosition,
                to: nextPosition
            )
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
