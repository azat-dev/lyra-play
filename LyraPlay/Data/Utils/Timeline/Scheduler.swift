//
//  Scheduler.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 13.07.22.
//

import Foundation

// MARK: - Interfaces

public protocol Scheduler: AnyObject {
    
    func execute(timeline: TimeLineIterator, from: TimeInterval, block: @escaping (TimeInterval) -> Void)
    
    func stop()
    
    func pause()
    
    func resume()
    
    var isActive: Bool { get }
}

// MARK: - Implementations

public final class DefaultScheduler {
    
    typealias Callback = (TimeInterval) -> Void
    
    private var timer: ActionTimer
    
    private var semaphore = DispatchSemaphore(value: 1)
    private var isStopped: Bool = false
    
    private var currentSession: Session? = nil
    
    public init(timer: ActionTimer) {
        self.timer = timer
    }
}

// MARK: - Methods

extension DefaultScheduler: Scheduler {
    
    public var isActive: Bool {
        
        semaphore.wait()
        defer { semaphore.signal() }
        
        return currentSession != nil
        
    }
    
    private func setNextTimer(block: @escaping Callback, lastTimeMark: TimeInterval = 0, delta: TimeInterval = 0) {
        
        semaphore.wait()
        
        guard let currentSession = currentSession else {
            semaphore.signal()
            return
        }
        
        semaphore.signal()
        
        guard let nextTimeMark = currentSession.timeline.getTimeOfNextEvent() else {
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
            let _ = currentSession.timeline.moveToNextEvent()

            self.semaphore.wait()
            self.currentSession?.lastIterationStartTime = nil
            self.currentSession?.lastTimeMark = nextTimeMark
            
            let prevSession = currentSession
            
            self.semaphore.signal()
            
            let timeDelta = Date.now.timeIntervalSince(triggerTime) - timeOffset
            block(nextTimeMark)

            
            self.semaphore.wait()
            
            let isSessionChanged = self.currentSession !== prevSession
            self.semaphore.signal()

            guard !isSessionChanged else {
                return
            }
            
            self.setNextTimer(
                block: block,
                lastTimeMark: nextTimeMark,
                delta: timeDelta
            )
        }
    }
    
    public func execute(timeline: TimeLineIterator, from time: TimeInterval, block: @escaping (TimeInterval) -> Void) {
        
        semaphore.wait()
        
        timer.cancel()
        
        currentSession = .init(
            lastIterationStartTime: nil,
            lastTimeMark: 0,
            timeline: timeline,
            block: block
        )
        
        semaphore.signal()
        
        guard let currentTimeMark = timeline.beginNextExecution(from: time) else {

            setNextTimer(block: block)
            return
        }
        
        if time == currentTimeMark {
            
            semaphore.wait()
            currentSession?.lastIterationStartTime = nil
            currentSession?.lastTimeMark = currentTimeMark
            let prevSession = currentSession
            semaphore.signal()
            
            
            block(currentTimeMark)
            
            semaphore.wait()
            let isSessionChanged = prevSession !== self.currentSession
            semaphore.signal()
            
            if isSessionChanged {
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
        var timeline: TimeLineIterator
        var block: (TimeInterval) -> Void
        
        init(
            lastIterationStartTime: Date? = nil,
            lastTimeMark: TimeInterval,
            timeline: TimeLineIterator,
            block: @escaping DefaultScheduler.Callback
        ) {
            self.lastIterationStartTime = lastIterationStartTime
            self.lastTimeMark = lastTimeMark
            self.block = block
            self.timeline = timeline
        }
        
        init(from source: Session) {
            
            self.lastIterationStartTime = source.lastIterationStartTime
            self.timeline = source.timeline
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
