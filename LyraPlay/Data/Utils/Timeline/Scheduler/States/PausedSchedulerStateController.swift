//
//  PausedSchedulerStateController.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 23.02.23.
//

import Foundation

public class PausedSchedulerStateController: SchedulerStateController {
    
    private var pasedAt: Date!
    
    private var elapsedTime: TimeInterval = 0
    
    private let timer: ActionTimer
    private let timeline: TimeLineIterator
    
    private weak var delegate: SchedulerStateControllerDelegate?
    private weak var delegateChanges: SchedulerDelegateChanges?
    
    // MARK: - Initializers
    
    public init(
        timer: ActionTimer,
        timeline: TimeLineIterator,
        delegate: SchedulerStateControllerDelegate,
        delegateChanges: SchedulerDelegateChanges?
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
    
    
    public func run(elapsedTime: TimeInterval) {
        
        self.pasedAt = .now
        self.elapsedTime = elapsedTime
        timer.cancel()
    }
}
