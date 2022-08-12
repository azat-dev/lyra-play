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
        iterator: TimeLineIteratorMock,
        timer: ActionTimerMock
    )
    
    func createSUT(file: StaticString = #filePath, line: UInt = #line) -> SUT {
        
        let iterator = TimeLineIteratorMock()

        let timer = ActionTimerMock()
        
        let scheduler = DefaultScheduler(
            timeLineIterator: iterator,
            timer: timer
        )
        
        detectMemoryLeak(instance: scheduler, file: file, line: line)
        
        return (
            scheduler,
            iterator,
            timer
        )
    }
    
    func test_start__empty_iterator() async throws {

        let expectation = expectation(description: "Don't call")
        expectation.isInverted = true

        let sut = createSUT()

        sut.iterator.timeMarks = []
        sut.scheduler.start(at: 0.0) { _ in
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
    }

    func test_start__at_zero() async throws {

        let sut = createSUT()

        let timeMarks = [0.0, 0.1, 0.2]

        let sequence = expectSequence(timeMarks)

        sut.iterator.timeMarks = timeMarks
        sut.scheduler.start(at: 0.0) { time in

            sequence.fulfill(with: time)
        }

        sequence.wait(timeout: 1, enforceOrder: true)
    }

    func test_start__at_offset() async throws {

        let sut = createSUT()

        let timeMarks = [0.0, 0.1, 0.2]
        let sequence = expectSequence([0.1, 0.2])

        sut.iterator.timeMarks = timeMarks

        sut.scheduler.start(at: 0.1) { time in

            sequence.fulfill(with: time)
        }

        sequence.wait(timeout: 1, enforceOrder: true)
    }

    func test_pause() async throws {

        let sut = createSUT()
        let scheduler = sut.scheduler

        let sequence = expectSequence([1.0, 2])

        sut.iterator.timeMarks = [1, 2, 3]

        sut.timer.willFire(filter: { _, _ in true })
        sut.scheduler.start(at: 0.0) { [weak scheduler] time in

            sequence.fulfill(with: time)

            if time == 2 {
                scheduler?.pause()
            }
        }

        sequence.wait(timeout: 1, enforceOrder: true)
    }

    func test_stop() async throws {

        let sut = createSUT()

        let expectation = expectation(description: "Don't call")
        expectation.isInverted = true

        sut.scheduler.start(at: 0.0) { _ in
            expectation.fulfill()
        }
        sut.scheduler.stop()

        wait(for: [expectation], timeout: 1)
    }

    func test_resume__paused() async throws {
        
        let sut = createSUT()
        let scheduler = sut.scheduler
        
        let sequence = expectSequence([1.0, 2, 3])
        
        sut.iterator.timeMarks = [1, 2, 3]

        sut.timer.willFire(filter: { _, _ in true })
        sut.scheduler.start(at: 0.0) { [weak scheduler] time in

            sequence.fulfill(with: time)

            if time == 2 {
                print("Pause")
                scheduler?.pause()
                print("Resume")
                scheduler?.resume()
            }
        }
        
        sequence.wait(timeout: 10, enforceOrder: true)
    }
}

// MARK: - Mocks

final class ActionTimerMock: ActionTimer {

    // MARK: - Properties
    
    typealias ExecutionBlock = () async -> Void
    typealias FilterCallback = (TimeInterval, Bool) -> Bool
    
    struct Promise {
        
        var isFulfilled: Bool = false
        var time: TimeInterval?
    }
    
    public var isCancelled = false
    
    private var filter: FilterCallback? = { _, _ in true }
    
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
            
            if filter(lastMessage.interval, isCancelled) {
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

        print("Start timer \(interval)")
        isCancelled = false
        self.lastMessage = (interval, block)
    }
    
    func cancel() {
    
        print("Cancel timer")
        isCancelled = true
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

final class TimeLineIteratorMock: TimeLineIterator {
    
    private var semaphore = DispatchSemaphore(value: 1)
    public var currentIndex = -1
    public var timeMarks = [TimeInterval]()

    var lastEventTime: TimeInterval? {
        return timeMarks[currentIndex]
    }
    
    func beginNextExecution(from time: TimeInterval) -> TimeInterval? {
        
        let recentIndex = timeMarks.lastIndex { $0 <= time }
        
        guard let recentIndex = recentIndex else {
            return nil
        }

        currentIndex = recentIndex
        print("Change index1 \(currentIndex)")
        return lastEventTime
    }
    
    func getTimeOfNextEvent() -> TimeInterval? {
        
        let nextIndex = currentIndex + 1
        
        guard nextIndex < timeMarks.count else {
            return nil
        }
        
        return timeMarks[nextIndex]
    }
    
    func moveToNextEvent() -> TimeInterval? {
        
        guard let next = getTimeOfNextEvent() else {
            return nil
        }

        currentIndex += 1
        print("Change index2 \(currentIndex)")
        return next
    }
}
