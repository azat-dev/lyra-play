//
//  PlaySubtitlesUseCaseImpl.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 23.02.23.
//

import Foundation
import Combine

public final class PlaySubtitlesUseCaseImpl: PlaySubtitlesUseCase {
    
    // MARK: - Properties
    
    public var state =  CurrentValueSubject<PlaySubtitlesUseCaseState, Never>(.initial)
    
    public let subtitlesTimeSlot = CurrentValueSubject<SubtitlesTimeSlot?, Never>(nil)
    
    public weak var delegate: PlaySubtitlesUseCaseDelegate?
    
    private let subtitlesIterator: SubtitlesIterator
    
    private let schedulerFactory: TimelineSchedulerFactory
    
    public var timeSlots: [SubtitlesTimeSlot] {
        
        return subtitlesIterator.timeSlots
    }
    
    private lazy var scheduler: TimelineScheduler = {
        
        return schedulerFactory.make(
            timeline: subtitlesIterator,
            delegate: self
        )
    } ()
    
    // MARK: - Initializers
    
    public init(
        subtitlesIterator: SubtitlesIterator,
        schedulerFactory: TimelineSchedulerFactory,
        delegate: PlaySubtitlesUseCaseDelegate?
    ) {
        
        self.subtitlesIterator = subtitlesIterator
        self.schedulerFactory = schedulerFactory
        self.delegate = delegate
    }
}

extension PlaySubtitlesUseCaseImpl: TimelineSchedulerDelegateChanges {
    
    public func schedulerWillChange(from: TimeInterval?, to: TimeInterval?, interrupt: inout Bool) {
        
        delegate?.playSubtitlesUseCaseWillChange(
            from: subtitlesIterator.currentTimeSlot,
            to: subtitlesIterator.getNextTimeSlot(),
            interrupt: &interrupt
        )
        
        if interrupt {
            
            let _ = pause()
        }
    }
    
    public func schedulerDidChange(time: TimeInterval) {
        
        subtitlesTimeSlot.value = subtitlesIterator.currentTimeSlot
        
        delegate?.playSubtitlesUseCaseDidChange(
            timeSlot: subtitlesIterator.currentTimeSlot
        )
    }
    
    public func schedulerDidStart() {
        
        state.value = .playing
    }
    
    public func schedulerDidPause() {
        
        state.value = .paused
    }
    
    public func schedulerDidStop() {
        
        state.value = .stopped
    }
    
    public func schedulerDidFinish() {
        
        state.value = .finished
        delegate?.playSubtitlesUseCaseDidFinish()
    }
}

// MARK: - Input Methods

extension PlaySubtitlesUseCaseImpl {
    
    public func play(atTime fromTime: TimeInterval) {
        
        scheduler.execute(from: fromTime)
    }
    
    public func resume() -> Void {
        
        scheduler.resume()
    }
    
    public func pause() -> Void {
        
        scheduler.pause()
    }
    
    public func stop() -> Void {
        
        scheduler.stop()
    }
    
    public func setTime(_ time: TimeInterval) {
        
        scheduler.setTime(time)
    }
    
    public func getPosition(for time: TimeInterval) -> SubtitlesTimeSlot? {
        
        return subtitlesIterator.getPosition(for: time)
    }
}
