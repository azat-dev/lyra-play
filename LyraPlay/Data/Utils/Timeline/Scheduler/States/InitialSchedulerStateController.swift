//
//  InitialSchedulerStateController.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 22.02.23.
//

import Foundation

public final class InitialSchedulerStateController: SchedulerStateController {
    
    // MARK: - Properties
    
    public let timer: ActionTimer
    public let timeline: TimeLineIterator
    public weak var delegate: SchedulerStateControllerDelegate?
    public weak var delegateChanges: SchedulerDelegateChanges?
    
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
    
    public func run() {
        
        timer.cancel()
    }
}
