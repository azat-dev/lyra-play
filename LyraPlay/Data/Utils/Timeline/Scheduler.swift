//
//  Scheduler.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 13.07.22.
//

import Foundation

// MARK: - Interfaces

public protocol SchedulerOutput {
    
    var isActive: Bool { get }
}

public protocol SchedulerInput {
    
    typealias DidChangeCallback = (TimeInterval) -> Void
    typealias WillChangeCallback = (_ from: TimeInterval?, _ to: TimeInterval?) -> Void
    
    var isActive: Bool { get }
    
    func execute(timeline: TimeLineIterator, from: TimeInterval, didChange: @escaping DidChangeCallback, willChange: WillChangeCallback?)
    
    func execute(timeline: TimeLineIterator, from: TimeInterval, didChange: @escaping DidChangeCallback)
    
    func stop()
    
    func pause()
    
    func resume()
}

public protocol Scheduler: AnyObject, SchedulerInput, SchedulerOutput {
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
    
    private func isSessionChanged(session: Session?) -> Bool {
        
        semaphore.wait()
        defer { semaphore.signal() }
        
        return currentSession !== session
    }
    
    @discardableResult
    private func updateSession(_ update: (Session?) -> Session?) -> Session? {
        
        semaphore.wait()
        defer { semaphore.signal() }
        
        currentSession = update(currentSession)
        return currentSession
    }
    
    private func getSession() -> Session? {
        
        semaphore.wait()
        defer { semaphore.signal() }
        
        return currentSession
    }
    
    private func setNextTimer(from baseTime: TimeInterval, delta: TimeInterval = 0) {
        
        guard
            let currentSession = getSession(),
            let nextTimeMark = currentSession.timeline.getTimeOfNextEvent()
        else {
            return
        }
        
        let triggerTime = Date.now
        let timeOffset = nextTimeMark - baseTime - delta
        
        timer.executeAfter(timeOffset) { [weak self] in
        
            guard
                let self = self,
                !self.isSessionChanged(session: currentSession)
            else {
                return
            }
            
            currentSession.willChange?(currentSession.timeline.lastEventTime, nextTimeMark)
            if self.isSessionChanged(session: currentSession) {
                return
            }
            
            self.semaphore.wait()
            let _ = currentSession.timeline.moveToNextEvent()
            self.semaphore.signal()
            
            currentSession.didChange(nextTimeMark)

            if self.isSessionChanged(session: currentSession) {
                return
            }
            
            let timeDelta = Date.now.timeIntervalSince(triggerTime) - timeOffset
            self.setNextTimer(
                from: nextTimeMark,
                delta: timeDelta
            )
        }
    }
    
    public func execute(timeline: TimeLineIterator, from: TimeInterval, didChange: @escaping DidChangeCallback) {
        execute(timeline: timeline, from: from, didChange: didChange, willChange: nil)
    }
    
    public func execute(timeline: TimeLineIterator, from time: TimeInterval, didChange: @escaping DidChangeCallback, willChange: WillChangeCallback?) {
        
        let session = updateSession { _ -> Session in
            
            timer.cancel()

            return .init(
                timeline: timeline,
                didChange: didChange,
                willChange: willChange
            )
        }
        
        guard let currentTimeMark = timeline.beginNextExecution(from: time) else {
            
            setNextTimer(from: time)
            return
        }
        
        if time == currentTimeMark {
            
            session?.willChange?(nil, currentTimeMark)
            
            if self.isSessionChanged(session: session) {
                return
            }
            
            session?.didChange(currentTimeMark)
            
            if self.isSessionChanged(session: session) {
                return
            }
        }
        
        setNextTimer(from: time)
    }
    
    public func stop() {
        
        updateSession { session -> Session? in
            
            timer.cancel()
            return nil
        }
    }
    
    public func pause() {
        
        updateSession { session -> Session? in
     
            timer.cancel()
            
            guard let currentSession = session else {
                return session
            }
            
            return currentSession.paused()
        }
    }
    
    public func resume() {
        
        semaphore.wait()
        
        guard let currentSession = currentSession else {
            semaphore.signal()
            return
        }
        
        timer.cancel()
        
        let elapsedTime = currentSession.elapsedTime
        self.currentSession = Session(from: currentSession)
        
        semaphore.signal()
        setNextTimer(from: elapsedTime)
    }
}

extension DefaultScheduler {
    
    private class Session {
        
        let timeline: TimeLineIterator
        var didChangeOriginal: Scheduler.DidChangeCallback
        var willChange: Scheduler.WillChangeCallback?
        
        var updatedAt: Date?
        var elapsedTime: TimeInterval = 0
        
        lazy var didChange: Scheduler.DidChangeCallback = {
            
            return {[weak self] time in
                
                self?.didGoThrough(timeMark: time)
                self?.didChangeOriginal(time)
            }
        } ()

        required init(
            timeline: TimeLineIterator,
            didChange: @escaping Scheduler.DidChangeCallback,
            willChange: Scheduler.WillChangeCallback?
        ) {

            self.timeline = timeline
            self.didChangeOriginal = didChange
            self.willChange = willChange
        }
        
        convenience init(from source: Session) {
            
            self.init(
                timeline: source.timeline,
                didChange: source.didChangeOriginal,
                willChange: source.willChange
            )
        }
        
        private func didGoThrough(timeMark: TimeInterval) {
            
            elapsedTime = timeMark
            updatedAt = .now
        }
        
        func paused() -> Session {
            
            guard let updatedAt = updatedAt else {
                return self
            }

            let newSession = Session(from: self)
            newSession.elapsedTime = elapsedTime + Date.now.timeIntervalSince(updatedAt)
            newSession.updatedAt = .now
            
            return newSession
        }
    }
}
