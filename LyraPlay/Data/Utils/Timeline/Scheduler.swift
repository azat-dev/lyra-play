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
    
    private let timeLineIterator: TimeLineIterator
    private var timer: ActionTimer
    
    private var semaphore = DispatchSemaphore(value: 1)
    private var isStopped: Bool = false
    
    public init(
        timeLineIterator: TimeLineIterator,
        timer: ActionTimer
    ) {
        
        self.timeLineIterator = timeLineIterator
        self.timer = timer
    }
}

extension DefaultScheduler: Scheduler {
    
    private func setNextTimer(block: @escaping (TimeInterval) -> Void, lastTimeMark: TimeInterval = 0, delta: TimeInterval = 0) {
        
        semaphore.wait()
        
        if isStopped {
            
            semaphore.signal()
            return
        }
        
        semaphore.signal()
        

        guard let nextTimeMark = timeLineIterator.getTimeOfNextEvent() else {
            return
        }
        
        let triggerTime = Date.now
        let timeOffset = nextTimeMark - lastTimeMark - delta
        
        timer.executeAfter(timeOffset) { [weak self] in

            guard let self = self else {
                return
            }
            
            self.semaphore.wait()
            
            if self.isStopped {
                
                self.semaphore.signal()
                return
            }
            
            self.semaphore.signal()
            
            
            let timeDelta = Date.now.timeIntervalSince(triggerTime) - timeOffset
            
            let _ = self.timeLineIterator.moveToNextEvent()
            
            block(nextTimeMark)
            
            self.setNextTimer(
                block: block,
                lastTimeMark: nextTimeMark,
                delta: timeDelta
            )
        }
    }
    
    public func start(at time: TimeInterval, block: @escaping (TimeInterval) -> Void) {
        
        semaphore.wait()
        
        timer.cancel()
        isStopped = false

        semaphore.signal()

        guard let currentTimeMark = timeLineIterator.beginNextExecution(from: time) else {
            setNextTimer(block: block)
            return
        }
        
        if time == currentTimeMark {
            
            block(currentTimeMark)
        }
        
        setNextTimer(block: block)
    }
    
    public func stop() {
        
        defer { semaphore.signal() }
        semaphore.wait()
        
        isStopped = true
        timer.cancel()
        
        let _ = timeLineIterator.beginNextExecution(from: 0)
    }
    
    public func pause() {
        
        defer { semaphore.signal() }
        semaphore.wait()
        
        isStopped = true
        timer.cancel()
    }
}
