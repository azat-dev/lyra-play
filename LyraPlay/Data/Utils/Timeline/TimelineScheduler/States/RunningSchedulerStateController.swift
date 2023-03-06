//
//  RunningSchedulerStateController.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 22.02.23.
//

import Foundation

public class RunningSchedulerStateController: TimelineSchedulerStateController {
    
    // MARK: - Properties
    
    public let timer: ActionTimer
    public let timeline: TimeLineIterator
    
    public weak var delegate: TimelineSchedulerStateControllerDelegate?
    public weak var delegateChanges: TimelineSchedulerDelegateChanges?
    
    private var startedAt: Date!
    private var baseOffset: TimeInterval = 0
    
    public var elapsedTime: TimeInterval {
        
        return Date.now.timeIntervalSince(startedAt) + baseOffset
    }
    
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
    
    public func stop() {
        
        delegate?.stop(
            timer: timer,
            timeline: timeline,
            delegateChanges: delegateChanges
        )
    }
    
    public func pause() {
        
        delegate?.pause(
            elapsedTime: elapsedTime,
            timer: timer,
            timeline: timeline,
            delegateChanges: delegateChanges
        )
    }
    
    public func resume() {}
    
    public func execute(from time: TimeInterval) {
        
        delegate?.execute(
            timer: timer,
            timeline: timeline,
            from: time,
            delegateChanges: delegateChanges
        )
    }
    
    private func change(to newTimeMark: TimeInterval, withDelta delta: TimeInterval) {
        
        var interrupt = false
        
        delegateChanges?.schedulerWillChange(
            from: timeline.lastEventTime,
            to: newTimeMark,
            interrupt: &interrupt
        )
        
        if interrupt {
            return
        }
        
        let _ = timeline.moveToNextEvent()
        
        delegateChanges?.schedulerDidChange(time: newTimeMark)
        
        guard
            let nextTimeMark = timeline.getTimeOfNextEvent()
        else {
            delegate?.didFinish()
            return
        }
        
        let timeOffset = max(nextTimeMark - elapsedTime, 0)
        
        timer.executeAfter(timeOffset) { [weak self] in
            
            guard let self = self else {
                return
            }
            
            let delta = Date.now.timeIntervalSince(self.startedAt) - nextTimeMark
            self.change(to: nextTimeMark, withDelta: delta)
        }
    }
    
    public func runExecution(from time: TimeInterval) {
        
        self.baseOffset = time
        self.startedAt = .now
        
        timer.cancel()
        
        let _ = timeline.beginNextExecution(from: time)
        
        guard
            let nextTimeMark = timeline.getTimeOfNextEvent()
        else {
            delegate?.didFinish()
            return
        }
        
        delegate?.didStartExecuting(withController: self)
        
        let timeOffset = max(nextTimeMark - elapsedTime, 0)

        timer.executeAfter(timeOffset) { [weak self] in
            
            guard let self = self else {
                return
            }
            
            let delta = Date.now.timeIntervalSince(self.startedAt) - nextTimeMark
            self.change(to: nextTimeMark, withDelta: delta)
        }
    }
}
