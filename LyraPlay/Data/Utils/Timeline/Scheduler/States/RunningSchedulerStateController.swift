//
//  RunningSchedulerStateController.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 22.02.23.
//

import Foundation

public class RunningSchedulerStateController: SchedulerStateController {
    
    // MARK: - Properties
    
    public let timer: ActionTimer
    public let timeline: TimeLineIterator
    
    public weak var delegate: SchedulerStateControllerDelegate?
    public weak var delegateChanges: SchedulerDelegateChanges?
    
    private var startedAt: Date!
    private var baseOffset: TimeInterval = 0
    private var deltaSum: TimeInterval = 0
    
    public var elapsedTime: TimeInterval {
        
        return baseOffset + startedAt.timeIntervalSinceNow
    }
    
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
        
        var stop = false
        
        delegateChanges?.schedulerWillChange(
            from: timeline.lastEventTime,
            to: newTimeMark,
            stop: &stop
        )
        
        if stop {
            return
        }
        
        let _ = timeline.moveToNextEvent()
        
        delegateChanges?.schedulerDidChange(time: newTimeMark)
        
        guard
            let nextTimeMark = timeline.getTimeOfNextEvent()
        else {
            delegateChanges?.schedulerDidFinish()
            return
        }
        
        let timeOffset = nextTimeMark - newTimeMark - delta
        
        timer.executeAfter(timeOffset) { [weak self] in
            
            guard let self = self else {
                return
            }
            
            let delta = self.startedAt.timeIntervalSinceNow - nextTimeMark
            
            self.change(to: nextTimeMark, withDelta: delta)
        }
    }
    
    public func run(from time: TimeInterval) {
        
        self.baseOffset = time
        
        timer.cancel()
        
        let _ = timeline.beginNextExecution(from: time)
        
        guard
            let nextTimeMark = timeline.getTimeOfNextEvent()
        else {
            delegateChanges?.schedulerDidFinish()
            return
        }
        
        self.startedAt = Date.now
        
        timer.executeAfter(nextTimeMark) { [weak self] in
            
            guard let self = self else {
                return
            }
            
            let delta = self.startedAt.timeIntervalSinceNow - nextTimeMark
            
            self.change(to: nextTimeMark, withDelta: delta)
        }
    }
}
