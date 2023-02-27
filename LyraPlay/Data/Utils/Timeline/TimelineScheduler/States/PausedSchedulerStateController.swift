//
//  PausedSchedulerStateController.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 23.02.23.
//

import Foundation

public class PausedSchedulerStateController: TimelineSchedulerStateController {
    
    private var pasedAt: Date!
    
    private var elapsedTime: TimeInterval = 0
    
    private let timer: ActionTimer
    private let timeline: TimeLineIterator
    
    private weak var delegate: TimelineSchedulerStateControllerDelegate?
    private weak var delegateChanges: TimelineSchedulerDelegateChanges?
    
    // MARK: - Initializers
    
    public init(
        timer: ActionTimer,
        timeline: TimeLineIterator,
        delegate: TimelineSchedulerStateControllerDelegate,
        delegateChanges: TimelineSchedulerDelegateChanges?
    ) {
        
        self.timer = timer
        self.timeline = timeline
        self.delegate = delegate
        self.delegateChanges = delegateChanges
    }
    
    
    // MARK: - Methods
    
    public func resume() {
        
        delegate?.execute(
            timer: timer,
            timeline: timeline,
            from: elapsedTime,
            delegateChanges: delegateChanges
        )
    }
    
    public func execute(from time: TimeInterval) {
        
        delegate?.execute(
            timer: timer,
            timeline: timeline,
            from: time,
            delegateChanges: delegateChanges
        )
    }
    
    public func stop() {
        
        delegate?.stop(
            timer: timer,
            timeline: timeline,
            delegateChanges: delegateChanges
        )
    }
    
    public func pause() {
    }
    
    
    public func runPausing(elapsedTime: TimeInterval) {
        
        self.pasedAt = .now
        self.elapsedTime = elapsedTime
        timer.cancel()
    }
}
