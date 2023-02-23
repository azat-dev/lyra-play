//
//  TimelineSchedulerFactoryImpl.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 31.08.22.
//

import Foundation

public final class TimelineSchedulerImplFactory: TimelineSchedulerFactory {
    
    // MARK: - Properties
    
    private let actionTimerFactory: ActionTimerFactory
    
    // MARK: - Initializers
    
    public init(actionTimerFactory: ActionTimerFactory) {
        
        self.actionTimerFactory = actionTimerFactory
    }
    
    // MARK: - Methods
    
    public func make(
        timeline: TimeLineIterator,
        delegate: TimelineSchedulerDelegateChanges
    ) -> TimelineScheduler {
        
        let actionTimer = actionTimerFactory.make()
        
        return TimelineSchedulerImpl(
            timer: actionTimer,
            timeline: timeline,
            delegateChanges: delegate
        )
    }
}
