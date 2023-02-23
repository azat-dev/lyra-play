//
//  PlaySubtitlesUseCaseImpl.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 31.08.2022.
//

import Foundation
import Combine

public final class PlaySubtitlesUseCaseImpl: PlaySubtitlesUseCase {

    // MARK: - Properties

    private let subtitlesIterator: SubtitlesIterator
    public var state =  CurrentValueSubject<PlaySubtitlesUseCaseState, Never>(.initial)
    public var willChangePosition = PassthroughSubject<WillChangeSubtitlesPositionData, Never>()

    private let schedulerFactory: TimelineSchedulerFactory
    
    private lazy var scheduler: TimelineScheduler = {
        
        return schedulerFactory.make(
           timeline: subtitlesIterator,
           delegate: self
       )
    } ()

    // MARK: - Initializers

    public init(
        subtitlesIterator: SubtitlesIterator,
        schedulerFactory: TimelineSchedulerFactory
    ) {

        self.subtitlesIterator = subtitlesIterator
        self.schedulerFactory = schedulerFactory
    }
}

// MARK: - SchedulerDelegateChanges

extension PlaySubtitlesUseCaseImpl: TimelineSchedulerDelegateChanges {
    
    
    public func schedulerDidChange(time: TimeInterval) {
        
        let isLast = subtitlesIterator.getTimeOfNextEvent() == nil
        
        if isLast {
            state.value = .finished
            return
        }
        
        state.value = .playing(position: subtitlesIterator.currentPosition)
    }
    
    public func schedulerWillChange(from fromTime: TimeInterval?, to: TimeInterval?, stop: inout Bool) {
        
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
    
    public func schedulerDidFinish() {
        
    }
}

// MARK: - Input Methods

extension PlaySubtitlesUseCaseImpl {
    
    private func play(from fromTime: TimeInterval) {
        
        scheduler.execute(from: fromTime)
        scheduler.execute(from: fromTime)
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
