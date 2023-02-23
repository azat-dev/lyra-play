//
//  Scheduler.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 13.07.22.
//

import Foundation

// MARK: - Interfaces

public protocol SchedulerDelegateChanges: AnyObject {
    
    func schedulerDidChange(time: TimeInterval) -> Void
    
    func schedulerWillChange(from: TimeInterval?, to: TimeInterval?, stop: inout Bool) -> Void
    
    func schedulerDidFinish()
}

public protocol SchedulerOutput: AnyObject {
    
    var isActive: Bool { get }
}

public protocol SchedulerInput: AnyObject {
    
    func execute(from: TimeInterval)
    
    func stop()
    
    func pause()
    
    func resume()
}

public protocol Scheduler: SchedulerOutput, SchedulerInput {
}
