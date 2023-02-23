//
//  PlaySubtitlesUseCaseImplNew.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 23.02.23.
//

import Foundation
import Combine

public final class PlaySubtitlesUseCaseImplNew: PlaySubtitlesUseCase {
    
    // MARK: - Properties
    
    private let subtitlesIterator: SubtitlesIterator
    public var state =  CurrentValueSubject<PlaySubtitlesUseCaseState, Never>(.initial)
    public var willChangePosition = PassthroughSubject<WillChangeSubtitlesPositionData, Never>()
    
    private let schedulerFactory: TimelineSchedulerFactory
    
    public weak var delegate: PlaySubtitlesUseCaseDelegate?
    
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

extension PlaySubtitlesUseCaseImplNew: TimelineSchedulerDelegateChanges {
    
    public func schedulerWillChange(from: TimeInterval?, to: TimeInterval?, stop: inout Bool) {
        
        delegate?.playSubtitlesUseCaseWillChange(
            fromPosition: subtitlesIterator.currentPosition,
            toPosition: subtitlesIterator.getNextPosition(),
            stop: &stop
        )
    }
    
    public func schedulerDidChange(time: TimeInterval) {
        
        delegate?.playSubtitlesUseCaseDidChange(
            position: subtitlesIterator.currentPosition
        )
    }
    
    public func schedulerDidFinish() {
     
        delegate?.playSubtitlesUseCaseDidFinish()
    }
}

// MARK: - Input Methods

extension PlaySubtitlesUseCaseImplNew {
    
    public func play(atTime fromTime: TimeInterval) {
        
        scheduler.execute(from: fromTime)
    }
    
    public func play() -> Void {

        scheduler.execute(from: 0)
    }
    
    public func pause() -> Void {

        scheduler.pause()
    }
    
    public func stop() -> Void {

        scheduler.stop()
    }
}
