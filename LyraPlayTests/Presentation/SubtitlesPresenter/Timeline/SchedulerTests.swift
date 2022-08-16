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
        timer: ActionTimer
    )
    
    func createSUT(file: StaticString = #filePath, line: UInt = #line) -> SUT {
        
        let iterator = TimeLineIteratorMock()
        
        let timer = ActionTimerMock2()
        
        let scheduler = DefaultScheduler(timer: timer)
        detectMemoryLeak(instance: scheduler, file: file, line: line)
        
        return (
            scheduler,
            iterator,
            timer
        )
    }
    
    func testIteration(
        sut: SUT,
        timeMarks: [TimeInterval],
        expectedDidChangeItems: [TimeInterval],
        expectedWillChangeItems: [ExpectedWillChange],
        startFrom: TimeInterval,
        waitFor: TimeInterval = 1,
        actionsOnDidChange: Scheduler.DidChangeCallback? = nil,
        actionsOnWillChange: Scheduler.WillChangeCallback? = nil,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        
        let didChangeSequence = expectSequence(expectedDidChangeItems)
        let willChangeSequence = expectSequence(expectedWillChangeItems)
        
        sut.iterator.timeMarks = timeMarks
        
        sut.scheduler.execute(timeline: sut.iterator, from: startFrom) { time in
            
            didChangeSequence.fulfill(with: time, file: file, line: line)
            actionsOnDidChange?(time)
            
        } willChange: { from, to in
            
            willChangeSequence.fulfill(with: .init(from: from, to: to))
            actionsOnWillChange?(from, to)
        }
        
        didChangeSequence.wait(timeout: waitFor, enforceOrder: true, file: file, line: line)
        willChangeSequence.wait(timeout: waitFor, enforceOrder: true, file: file, line: line)
    }
    
    func test_execute__empty_iterator() async throws {
        
        let expectation = expectation(description: "Don't call")
        expectation.isInverted = true
        
        let sut = createSUT()
        
        testIteration(
            sut: sut,
            timeMarks: [],
            expectedDidChangeItems: [],
            expectedWillChangeItems: [],
            startFrom: 0,
            waitFor: 1,
            actionsOnDidChange: { _ in expectation.fulfill() },
            actionsOnWillChange: { _, _ in expectation.fulfill() }
        )
        
        wait(for: [expectation], timeout: 0.1)
    }
    
    func test_execute__at_zero() async throws {
        
        let sut = createSUT()
        
        testIteration(
            sut: sut,
            timeMarks: [0, 1, 2],
            expectedDidChangeItems: [0, 1, 2],
            expectedWillChangeItems: [
                .init(from: nil, to: 0),
                .init(from: 0, to: 1),
                .init(from: 1, to: 2)
            ],
            startFrom: 0,
            waitFor: 0.5
        )
    }
    
    func test_execute__at_offset() async throws {
        
        let sut = createSUT()
        
        testIteration(
            sut: sut,
            timeMarks: [0, 1, 2],
            expectedDidChangeItems: [1, 2],
            expectedWillChangeItems: [
                .init(from: nil, to: 1),
                .init(from: 1, to: 2)
            ],
            startFrom: 1,
            waitFor: 0.5
        )
        
        testIteration(
            sut: sut,
            timeMarks: [0, 1, 2],
            expectedDidChangeItems: [2],
            expectedWillChangeItems: [
                .init(from: nil, to: 2)
            ],
            startFrom: 2,
            waitFor: 0.5
        )
    }
    
    func test_pause__on_did_change() async throws {
        
        let sut = createSUT()
        let scheduler = sut.scheduler
        
        let elementAfterPauseExpectation = expectation(description: "Don't call")
        elementAfterPauseExpectation.isInverted = true
        
        testIteration(
            sut: sut,
            timeMarks: [1, 2, 3, 4],
            expectedDidChangeItems: [1, 2],
            expectedWillChangeItems: [
                .init(from: nil, to: 1),
                .init(from: 1, to: 2)
            ],
            startFrom: 1,
            waitFor: 0.5,
            actionsOnDidChange: { [weak scheduler] time in
                
                if time == 2 {
                    scheduler?.pause()
                }
                
                if time > 2 {
                    elementAfterPauseExpectation.fulfill()
                }
            }
        )
        
        wait(for: [elementAfterPauseExpectation], timeout: 0.1)
    }
    
    func test_pause__on_will_change() async throws {
        
        let sut = createSUT()
        let scheduler = sut.scheduler
        
        let elementAfterPauseExpectation = expectation(description: "Don't call")
        elementAfterPauseExpectation.isInverted = true
        
        testIteration(
            sut: sut,
            timeMarks: [1, 2, 3, 4],
            expectedDidChangeItems: [1],
            expectedWillChangeItems: [
                .init(from: nil, to: 1),
                .init(from: 1, to: 2)
            ],
            startFrom: 1,
            waitFor: 0.5,
            actionsOnWillChange: { [weak scheduler] fromTime, toTime in
                
                if toTime == 2 {
                    scheduler?.pause()
                }
                
                if (fromTime ?? 0) > 2 {
                    elementAfterPauseExpectation.fulfill()
                }
            }
        )
        
        wait(for: [elementAfterPauseExpectation], timeout: 0.1)
    }
    
    func test_resume() async throws {

        let sut = createSUT()
        let scheduler = sut.scheduler

        testIteration(
            sut: sut,
            timeMarks: [1, 2, 3, 4],
            expectedDidChangeItems: [1, 2, 3, 4],
            expectedWillChangeItems: [
                .init(from: nil, to: 1),
                .init(from: 1, to: 2),
                .init(from: 2, to: 3),
                .init(from: 3, to: 4)
            ],
            startFrom: 0,
            waitFor: 0.5,
            actionsOnDidChange: { [weak scheduler] time in

                if time == 2 {
                    scheduler?.pause()
                    
                    DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + 0.1) { [weak scheduler] in
                        scheduler?.resume()
                    }
                }
            }
        )
    }
    
    func test_stop__on_did_change() async throws {
        
        let sut = createSUT()
        let scheduler = sut.scheduler
        
        let elementAfterPauseExpectation = expectation(description: "Don't call")
        elementAfterPauseExpectation.isInverted = true
        
        testIteration(
            sut: sut,
            timeMarks: [1, 2, 3, 4],
            expectedDidChangeItems: [1, 2],
            expectedWillChangeItems: [
                .init(from: nil, to: 1),
                .init(from: 1, to: 2)
            ],
            startFrom: 1,
            waitFor: 0.5,
            actionsOnDidChange: { [weak scheduler] time in
                
                if time == 2 {
                    scheduler?.stop()
                }
                
                if time > 2 {
                    elementAfterPauseExpectation.fulfill()
                }
            }
        )
        
        wait(for: [elementAfterPauseExpectation], timeout: 0.1)
    }
    
    func test_stop__on_will_change() async throws {
        
        let sut = createSUT()
        let scheduler = sut.scheduler
        
        let elementAfterPauseExpectation = expectation(description: "Don't call")
        elementAfterPauseExpectation.isInverted = true
        
        testIteration(
            sut: sut,
            timeMarks: [1, 2, 3, 4],
            expectedDidChangeItems: [1, 2],
            expectedWillChangeItems: [
                .init(from: nil, to: 1),
                .init(from: 1, to: 2),
                .init(from: 2, to: 3)
            ],
            startFrom: 1,
            waitFor: 0.5,
            actionsOnWillChange: { [weak scheduler] fromTime, _ in
                
                if fromTime == 2 {
                    scheduler?.stop()
                }
                
                if (fromTime ?? -1) > 2 {
                    elementAfterPauseExpectation.fulfill()
                }
            }
        )
        
        wait(for: [elementAfterPauseExpectation], timeout: 0.1)
    }
}

// MARK: - Helpers
struct ExpectedWillChange: Equatable {
    
    var from: TimeInterval?
    var to: TimeInterval?
}

// MARK: - Mocks

final class ActionTimerMock2: ActionTimer {
    
    let timer = DefaultActionTimer()
    
    func executeAfter(_ interval: TimeInterval, block: @escaping () async -> Void) {
        timer.executeAfter(0.001, block: block)
    }
    
    func cancel() {
        timer.cancel()
    }
}


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
            DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + 0.1) {
                self.tryFulfill()
            }
            
        }
    }
    
    private var promises = [Promise]() {
        
        didSet {
            DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + 0.1) {
                self.tryFulfill()
            }
        }
    }
    
    // MARK: - Initializers
    
    init() {}
    
    // MARK: - Methods
    
    private func tryFulfill() {
        
        guard !isCancelled else {
            return
        }
        
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
        
        Task(priority: .userInitiated) {
            await lastMessage.block()
        }
    }
    
    func executeAfter(_ interval: TimeInterval, block: @escaping () async -> Void) {
        
        isCancelled = false
        self.lastMessage = (interval, block)
    }
    
    func cancel() {
        
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

        if currentIndex == -1 {
            return nil
        }

        return timeMarks[currentIndex]
    }
    
    func beginNextExecution(from time: TimeInterval) -> TimeInterval? {
        
        let recentIndex = timeMarks.lastIndex { $0 <= time }
        
        guard let recentIndex = recentIndex else {
            return nil
        }
        
        currentIndex = recentIndex
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
        return next
    }
}
