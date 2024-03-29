//
//  TimelineScheduler.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 13.07.22.
//

import Foundation

// MARK: - Interfaces

public protocol TimelineSchedulerDelegateChanges: AnyObject {
    
    func schedulerDidChange(time: TimeInterval) -> Void
    
    func schedulerWillChange(from: TimeInterval?, to: TimeInterval?, interrupt: inout Bool) -> Void
    
    func schedulerDidFinish()
    
    func schedulerDidStart()
    
    func schedulerDidPause()
    
    func schedulerDidStop()
}

public protocol TimelineSchedulerOutput: AnyObject {
    
    var isActive: Bool { get }
}

public protocol TimelineSchedulerInput: AnyObject {
    
    func execute(from: TimeInterval)
    
    func stop()
    
    func pause()
    
    func resume()
    
    func setTime(_ time: TimeInterval)
}

public protocol TimelineScheduler: TimelineSchedulerOutput, TimelineSchedulerInput {
}
