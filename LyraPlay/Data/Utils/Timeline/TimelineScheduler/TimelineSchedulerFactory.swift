//
//  TimelineSchedulerFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 31.08.22.
//

import Foundation

public protocol TimelineSchedulerFactory {
    
    func make(
        timeline: TimeLineIterator,
        delegate: TimelineSchedulerDelegateChanges
    ) -> TimelineScheduler
}
