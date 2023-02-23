//
//  TimelineSchedulerStateControllerDelegate.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 22.02.23.
//

import Foundation

public protocol TimelineSchedulerStateControllerDelegate: AnyObject {
    
    func execute(
        timer: ActionTimer,
        timeline: TimeLineIterator,
        from: TimeInterval,
        delegateChanges: TimelineSchedulerDelegateChanges?
    )
    
    func stop(
        timer: ActionTimer,
        timeline: TimeLineIterator,
        delegateChanges: TimelineSchedulerDelegateChanges?
    )
    
    func pause(
        elapsedTime: TimeInterval,
        timer: ActionTimer,
        timeline: TimeLineIterator,
        delegateChanges: TimelineSchedulerDelegateChanges?
    )
}
