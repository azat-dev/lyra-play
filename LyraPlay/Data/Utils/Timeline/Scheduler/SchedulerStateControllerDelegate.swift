//
//  SchedulerStateControllerDelegate.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 22.02.23.
//

import Foundation

public protocol SchedulerStateControllerDelegate: AnyObject {
    
    func execute(
        timer: ActionTimer,
        timeline: TimeLineIterator,
        from: TimeInterval,
        delegateChanges: SchedulerDelegateChanges?
    )
    
    func stop(
        timer: ActionTimer,
        timeline: TimeLineIterator,
        delegateChanges: SchedulerDelegateChanges?
    )
    
    func pause(
        elapsedTime: TimeInterval,
        timer: ActionTimer,
        timeline: TimeLineIterator,
        delegateChanges: SchedulerDelegateChanges?
    )
}
