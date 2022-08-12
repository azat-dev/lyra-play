//
//  Scheduler.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 13.07.22.
//

import Foundation

// MARK: - Interfaces

public protocol Scheduler: AnyObject {
    
    func start(at: TimeInterval, block: @escaping (TimeInterval) -> Void)
    
    func stop()
    
    func pause()
    
    func resume()
}

// MARK: - Implementations

public final class DefaultScheduler {
    
    typealias Callback = (TimeInterval) -> Void
    
    private let timeLineIterator: TimeLineIterator
    private var timer: ActionTimer
    
    private var semaphore = DispatchSemaphore(value: 1)
    private var isStopped: Bool = false
    
    private var currentSession: Session? = nil
    
    public init(
        timeLineIterator: TimeLineIterator,
        timer: ActionTimer
    ) {
        
        self.timeLineIterator = timeLineIterator
        self.timer = timer
    }
}

// MARK: - Methods

extension DefaultScheduler: Scheduler {
    
    private func setNextTimer(block: @escaping Callback, lastTimeMark: TimeInterval = 0, delta: TimeInterval = 0) {
        
        semaphore.wait()
        
        guard currentSession != nil else {
            semaphore.signal()
            return
        }
        
        semaphore.signal()
        
        guard let nextTimeMark = timeLineIterator.getTimeOfNextEvent() else {
            return
        }
        
        let triggerTime = Date.now
        let timeOffset = nextTimeMark - lastTimeMark - delta
        
        semaphore.wait()
        self.currentSession?.lastIterationStartTime = triggerTime
        semaphore.signal()
        
        timer.executeAfter(timeOffset) { [weak self] in
        
            guard let self = self else {
                return
            }
            
            self.semaphore.wait()

            guard let currentSession = self.currentSession else {
                self.semaphore.signal()
                return
            }
            
            self.semaphore.signal()
            let _ = self.timeLineIterator.moveToNextEvent()

            self.semaphore.wait()
            self.currentSession?.lastIterationStartTime = nil
            self.currentSession?.lastTimeMark = nextTimeMark
            
            let prevSession = currentSession
            
            self.semaphore.signal()
            
            let timeDelta = Date.now.timeIntervalSince(triggerTime) - timeOffset
            block(nextTimeMark)

            
            self.semaphore.wait()
            
            guard self.currentSession === prevSession else {
                self.semaphore.signal()
                return
            }
            
            self.semaphore.signal()
            
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
        
        currentSession = .init(
            lastIterationStartTime: nil,
            lastTimeMark: 0,
            block: block
        )
        
        semaphore.signal()
        
        guard let currentTimeMark = timeLineIterator.beginNextExecution(from: time) else {

            setNextTimer(block: block)
            return
        }
        
        if time == currentTimeMark {
            
            semaphore.wait()
            currentSession?.lastIterationStartTime = nil
            currentSession?.lastTimeMark = currentTimeMark
            semaphore.signal()
            
            let prevSession = currentSession
            
            block(currentTimeMark)
            
            if currentSession !== prevSession {
                return
            }
        }
        
        setNextTimer(block: block)
    }
    
    public func stop() {
        
        defer { semaphore.signal() }
        semaphore.wait()
        
        currentSession = nil
        timer.cancel()
        
        let _ = timeLineIterator.beginNextExecution(from: 0)
    }
    
    public func pause() {
        
        semaphore.wait()
        
        guard let currentSession = currentSession else {
            semaphore.signal()
            return
        }
        

        self.currentSession = .init(from: currentSession)
        self.currentSession?.pausedAt = .now

        timer.cancel()
        semaphore.signal()
    }
    
    public func resume() {
        
        semaphore.wait()
        
        
        guard let currentSession = currentSession else {
            semaphore.signal()
            return
        }
        
        timer.cancel()

        let elapsedTime = currentSession.getElapsedTime()
        
        self.currentSession = .init(from: currentSession)
        self.currentSession?.pausedAt = nil
        self.currentSession?.lastIterationStartTime = nil
        
        semaphore.signal()
        setNextTimer(block: currentSession.block, lastTimeMark: elapsedTime)
    }
}

extension DefaultScheduler {
    
    private class Session {
        
        var lastIterationStartTime: Date? = nil
        var lastTimeMark: TimeInterval = 0
        var pausedAt: Date? = nil
        var block: (TimeInterval) -> Void
        
        init(
            lastIterationStartTime: Date? = nil,
            lastTimeMark: TimeInterval,
            block: @escaping DefaultScheduler.Callback
        ) {
            self.lastIterationStartTime = lastIterationStartTime
            self.lastTimeMark = lastTimeMark
            self.block = block
        }
        
        init(from source: Session) {
            
            self.lastIterationStartTime = source.lastIterationStartTime
            self.lastTimeMark = source.lastTimeMark
            self.pausedAt = source.pausedAt
            self.block = source.block
        }
        
        func getElapsedTime() -> TimeInterval {

            guard
                let lastIterationStartTime = lastIterationStartTime,
                let pausedAt = pausedAt
            else {
                return lastTimeMark
            }
            
            return lastTimeMark + pausedAt.timeIntervalSince(lastIterationStartTime)
        }
    }
}
