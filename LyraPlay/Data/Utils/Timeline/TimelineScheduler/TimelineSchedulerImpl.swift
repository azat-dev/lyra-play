//
//  TimelineSchedulerImpl.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 22.02.23.
//

import Foundation

public final class TimelineSchedulerImpl: TimelineScheduler {
    
    // MARK: - Properties
    
    private var semaphore = DispatchSemaphore(value: 1)
    
    private let timer: ActionTimer
    private let timeline: TimeLineIterator
    private let delegateChanges: TimelineSchedulerDelegateChanges
    
    private lazy var currentController: TimelineSchedulerStateController = {
        
        return InitialSchedulerStateController(
            timer: timer,
            timeline: timeline,
            delegate: self,
            delegateChanges: delegateChanges
        )
    } ()
    
    public var isActive: Bool {
        fatalError()
    }
    
    // MARK: - Initializers
    
    public init(
        timer: ActionTimer,
        timeline: TimeLineIterator,
        delegateChanges: TimelineSchedulerDelegateChanges
    ) {
        
        self.timer = timer
        self.timeline = timeline
        self.delegateChanges = delegateChanges
    }
}

// MARK: - Methods

extension TimelineSchedulerImpl {
    
    public func pause() {
        
        self.currentController.pause()
    }
    
    public func resume() {
        
        self.currentController.resume()
    }
    
    public func stop() {
        
        self.currentController.stop()
    }
    
    public func execute(from time: TimeInterval) {
        
        self.currentController.execute(from: time)
    }
}

// MARK: - Delegate

extension TimelineSchedulerImpl: TimelineSchedulerStateControllerDelegate {
    
    public func execute(
        timer: ActionTimer,
        timeline: TimeLineIterator,
        from time: TimeInterval,
        delegateChanges: TimelineSchedulerDelegateChanges?
    ) {
        
        
        let newController = RunningSchedulerStateController(
            timer: timer,
            timeline: timeline,
            delegate: self,
            delegateChanges: delegateChanges
        )
        
        self.currentController = newController
        newController.run(from: time)
    }
    
    public func stop(
        timer: ActionTimer,
        timeline: TimeLineIterator,
        delegateChanges: TimelineSchedulerDelegateChanges?
    ) {
        
        let newController = InitialSchedulerStateController(
            timer: timer,
            timeline: timeline,
            delegate: self,
            delegateChanges: delegateChanges
        )
        
        self.currentController = newController
        newController.run()
    }
    
    public func pause(
        elapsedTime: TimeInterval,
        timer: ActionTimer,
        timeline: TimeLineIterator,
        delegateChanges: TimelineSchedulerDelegateChanges?
    ) {
        
        
        let newController = PausedSchedulerStateController(
            timer: timer,
            timeline: timeline,
            delegate: self,
            delegateChanges: delegateChanges
        )
        
        self.currentController = newController
        newController.run(elapsedTime: elapsedTime)
    }
}
