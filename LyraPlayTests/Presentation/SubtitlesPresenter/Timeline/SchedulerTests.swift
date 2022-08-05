//
//  SchedulerTests.swift
//  LyraPlayTests
//
//  Created by Azat Kaiumov on 13.07.22.
//

import Foundation
import XCTest
import LyraPlay

class SchedulerTests: XCTestCase {
    
    typealias SUT = (
        scheduler: Scheduler,
        iterator: TimeMarksIteratorMock,
        timer: ActionTimerMock
    )
    
    func createSUT() -> SUT {
        
        let iterator = TimeMarksIteratorMock()

        let timer = ActionTimerMock()
        
        let scheduler = DefaultScheduler(
            timeMarksIterator: iterator,
            timer: timer
        )
        
        detectMemoryLeak(instance: scheduler)
        
        return (
            scheduler,
            iterator,
            timer
        )
    }
    
    func testStartEmptyIterator() async throws {
        
        let expectation = expectation(description: "Don't call")
        expectation.isInverted = true
        
        let sut = createSUT()

        sut.iterator.timeMarks = []
        sut.scheduler.start(at: 0.0) { _ in
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1)
    }
    
    func testStartAtZero() async throws {
        
        let sut = createSUT()
        
        let timeMarks = [0.0, 0.1, 0.2]
        
        let sequence = expectSequence(timeMarks)
        
        sut.iterator.timeMarks = timeMarks
        sut.scheduler.start(at: 0.0) { time in
            
            sequence.fulfill(with: time)
        }
        
        sequence.wait(timeout: 1, enforceOrder: true)
    }
    
    func testStartAtOffset() async throws {
        

        let sut = createSUT()

        let timeMarks = [0.0, 0.1, 0.2]
        let sequence = expectSequence([0.1, 0.2])
        
        sut.iterator.timeMarks = timeMarks
        
        sut.scheduler.start(at: 0.1) { time in
            
            sequence.fulfill(with: time)
        }
        
        sequence.wait(timeout: 1, enforceOrder: true)
    }
    
    func testPause() async throws {
        
        let sut = createSUT()
        
        let expectation = expectation(description: "Don't call")
        expectation.isInverted = true
        
        sut.scheduler.start(at: 0.0) { _ in
            expectation.fulfill()
        }
        sut.scheduler.stop()
        
        wait(for: [expectation], timeout: 1)
    }
    
    
    func testStop() async throws {
        
        let sut = createSUT()
        
        let expectation = expectation(description: "Don't call")
        expectation.isInverted = true
        
        sut.scheduler.start(at: 0.0) { _ in
            expectation.fulfill()
        }
        sut.scheduler.stop()
        
        wait(for: [expectation], timeout: 1)
    }
}

// MARK: - Mocks

final class ActionTimerMock: ActionTimer {

    // MARK: - Properties
    
    typealias ExecutionBlock = () async -> Void
    typealias FilterCallback = (TimeInterval) -> Bool
    
    struct Promise {
        
        var isFulfilled: Bool = false
        var time: TimeInterval?
    }
    
    private var filter: FilterCallback? = { _ in true }
    
    private var lastMessage: (interval: TimeInterval, block: ExecutionBlock)? {
        
        didSet {
            tryFulfill()
        }
    }
    
    private var promises = [Promise]() {
        
        didSet {
            tryFulfill()
        }
    }
    
    // MARK: - Initializers
    
    init() {}
    
    // MARK: - Methods
    
    private func tryFulfill() {
        
        guard let lastMessage = lastMessage else {
            return
        }
        
        if let filter = filter {
            
            if filter(lastMessage.interval) {
                fire()
                return
            }
        }

        for index in 0..<promises.count {
            
            let promise = promises[index]
            if promise.isFulfilled {
                continue
            }
            
            if let time = promise.time,
               time == lastMessage.interval {
                
                var updatedPromise = promise
                updatedPromise.isFulfilled = true
                promises[index] = updatedPromise
                
                fire()
                return
            }
        }
    }
    
    func willFire(at time: TimeInterval) {
        
        promises.append(.init(isFulfilled: false, time: time))
    }
    
    func willFire(at times: [TimeInterval]) {

        times.forEach { time in willFire(at: time) }
    }
    
    func willFire(filter: FilterCallback?) {
        self.filter = filter
    }
    
    func fire() {
        
        guard let lastMessage = lastMessage else {
            return
        }

        self.lastMessage = nil
        
        Task {
            await lastMessage.block()
        }
    }
    
    func executeAfter(_ interval: TimeInterval, block: @escaping () async -> Void) {

        self.lastMessage = (interval, block)
    }
    
    func cancel() {
        
        lastMessage = nil
    }
}

final class ActionTimerFactoryMock: ActionTimerFactory {
    
    var timers = [ActionTimerMock]()
    
    func create() -> ActionTimer {

        let timer = ActionTimerMock()
        timers.append(timer)
        
        return timer
    }
}

final class TimeMarksIteratorMock: TimeMarksIterator {
    
    private var semaphore = DispatchSemaphore(value: 1)
    public var currentIndex = 0
    public var timeMarks = [TimeInterval]()

    var currentTime: TimeInterval? {
        return timeMarks[currentIndex]
    }
    
    func move(at time: TimeInterval) -> TimeInterval? {
        
        let recentIndex = timeMarks.lastIndex { $0 <= time }
        
        guard let recentIndex = recentIndex else {
            return nil
        }

        currentIndex = recentIndex
        return currentTime
    }
    
    func getNext() -> TimeInterval? {
        
        let nextIndex = currentIndex + 1
        
        guard nextIndex < timeMarks.count else {
            return nil
        }
        
        return timeMarks[nextIndex]
    }
    
    func next() -> TimeInterval? {
        
        guard let next = getNext() else {
            return nil
        }

        currentIndex += 1
        return next
    }
    
}
