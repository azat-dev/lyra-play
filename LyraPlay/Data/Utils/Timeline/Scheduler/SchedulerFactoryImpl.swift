//
//  SchedulerFactoryImpl.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 31.08.22.
//

import Foundation

public final class SchedulerImplFactory: SchedulerFactory {
    
    // MARK: - Properties
    
    private let actionTimerFactory: ActionTimerFactory
    
    // MARK: - Initializers
    
    public init(actionTimerFactory: ActionTimerFactory) {
        
        self.actionTimerFactory = actionTimerFactory
    }
    
    // MARK: - Methods
    
    public func make(
        timeline: TimeLineIterator,
        delegate: SchedulerDelegateChanges
    ) -> Scheduler {
        
        let actionTimer = actionTimerFactory.make()
        
        return SchedulerImpl(
            timer: actionTimer,
            timeline: timeline,
            delegateChanges: delegate
        )
    }
}
