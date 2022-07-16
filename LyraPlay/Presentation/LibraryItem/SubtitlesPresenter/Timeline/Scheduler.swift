//
//  Scheduler.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 13.07.22.
//

import Foundation

// MARK: - Interfaces

public protocol Scheduler {
    
    func start(at: TimeInterval, block: @escaping (TimeInterval) -> Void)
    
    func stop()
    
    func pause()
}

// MARK: - Implementations

public final class DefaultScheduler {
    
    private let timeMarksIterator: TimeMarksIterator
    private let actionTimerFactory: ActionTimerFactory
    private var timer: ActionTimer
    
    public init(
        timeMarksIterator: TimeMarksIterator,
        actionTimerFactory: ActionTimerFactory
    ) {
        
        self.timeMarksIterator = timeMarksIterator
        self.actionTimerFactory = actionTimerFactory
        self.timer = actionTimerFactory.create()
    }
}

extension DefaultScheduler: Scheduler {
    
    
    private func setNextTimer(block: @escaping (TimeInterval) -> Void, lastTimeMark: TimeInterval = 0, delta: TimeInterval = 0) {

        guard let nextTimeMark = timeMarksIterator.getNext() else {
            return
        }
        
        let triggerTime = Date.now
        let timeOffset = nextTimeMark - lastTimeMark + delta
        
        timer.executeAfter(timeOffset) { [weak self] in
            
            guard let self = self else {
                return
            }
            
            let timeDelta = Date.now.timeIntervalSince(triggerTime) * -1
            
            let _ = self.timeMarksIterator.next()
            
            self.setNextTimer(
                block: block,
                lastTimeMark: nextTimeMark,
                delta: timeDelta
            )
            block(nextTimeMark)
        }
    }
    
    public func start(at time: TimeInterval, block: @escaping (TimeInterval) -> Void) {
        
        timer.cancel()

        guard let currentTimeMark = timeMarksIterator.move(at: time) else {
            setNextTimer(block: block)
            return
        }
        
        if time == currentTimeMark {
            block(currentTimeMark)
        }
        
        setNextTimer(block: block)
    }
    
    public func stop() {
        
        timer.cancel()
    }
    
    public func pause() {
        
        timer.cancel()
    }
}
