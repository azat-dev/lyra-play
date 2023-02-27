//
//  InitialSchedulerStateController.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 22.02.23.
//

import Foundation

public final class InitialSchedulerStateController: TimelineSchedulerStateController {
    
    // MARK: - Properties
    
    public let timer: ActionTimer
    public let timeline: TimeLineIterator
    public weak var delegate: TimelineSchedulerStateControllerDelegate?
    public weak var delegateChanges: TimelineSchedulerDelegateChanges?
    
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
    
    public func stop() {}
    
    public func pause() {}
    
    public func resume() {}
    
    public func execute(from time: TimeInterval) {
        
        delegate?.execute(
            timer: timer,
            timeline: timeline,
            from: time,
            delegateChanges: delegateChanges
        )
    }
    
    public func runStop() {
        
        let _ = timeline.beginNextExecution(from: 0)
        timer.cancel()
        
        delegate?.didStop(withController: self)
    }
}
