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
    
    public let subtitlesPosition = CurrentValueSubject<SubtitlesPosition?, Never>(nil)
    
    public weak var delegate: PlaySubtitlesUseCaseDelegate?
    
    private let subtitlesIterator: SubtitlesIterator
    
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
        schedulerFactory: TimelineSchedulerFactory,
        delegate: PlaySubtitlesUseCaseDelegate?
    ) {
        
        self.subtitlesIterator = subtitlesIterator
        self.schedulerFactory = schedulerFactory
        self.delegate = delegate
    }
}

extension PlaySubtitlesUseCaseImpl: TimelineSchedulerDelegateChanges {
    
    public func schedulerWillChange(from: TimeInterval?, to: TimeInterval?, stop: inout Bool) {
        
        delegate?.playSubtitlesUseCaseWillChange(
            fromPosition: subtitlesIterator.currentPosition,
            toPosition: subtitlesIterator.getNextPosition(),
            stop: &stop
        )
    }
    
    public func schedulerDidChange(time: TimeInterval) {
        
        subtitlesPosition.value = subtitlesIterator.currentPosition
        
        delegate?.playSubtitlesUseCaseDidChange(
            position: subtitlesIterator.currentPosition
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
}
