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
        iterator: TimeMarksIterator,
        timerFactory: ActionTimerFactory
    )
    
    func createSUT() -> SUT {
        
        let timerFactory = ActionTimerFactoryMock()
        
        let scheduler = DefaultScheduler(
            iterator: iterator,
            timerFactory: timerFactory
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
        let iteratorData = [(0.0, 0.0)]

        sut.iterator.timeMarks = []
        sut.scheduler.start(at: 0.0) {
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1)
    }
    
    func testStartAtZero() async throws {
        
        let sut = createSUT()
        
        let iteratorData = [(0.0, 0), (0.1, 1), (0.2, 2)]
        
        let sequence = expectSequence([
            [0, 0.0, 0],
            [0, 0.1, 1],
            [0, 0.2, 2],
        ])
        
        sut.iterator.timeMarks = [0.0, 0.1, 0.2]
        sut.scheduler.start(at: 0.0) { index, time, data in
            
            sequence.fulfill(with: [index, time, data])
        }
        
        sequence.wait(timeout: 1, enforceOrder: true)
    }
    
    func testStartAtOffset() async throws {
        
        let sut = createSUT()
        
        let iteratorData = [(0.0, 0), (0.1, 1), (0.2, 2)]
        
        let sequence = expectSequence([
            [0, 0.0, 0],
            [0, 0.1, 1],
            [0, 0.2, 2],
        ])
        
        sut.iterator.timeMarks = [1]
        
        sut.scheduler.start(at: 0.1) { index, time, data in
            
            sequence.fulfill(with: [index, time, data])
        }
        
        sequence.wait(timeout: 1, enforceOrder: true)
    }
    
    func testPause() async throws {
        
        let sut = createSUT()
        
        let expectation = expectation(description: "Don't call")
        expectation.isInverted = true
        
        sut.scheduler.start(at: 0.0)
        sut.scheduler.stop()
        
        wait(for: [expectation], timeout: 1)
    }
    
    
    func testStop() async throws {
        
        let sut = createSUT()
        
        let expectation = expectation(description: "Don't call")
        expectation.isInverted = true
        
        sut.scheduler.start(at: 0.0)
        sut.scheduler.stop()
        
        wait(for: [expectation], timeout: 1)
    }
}

// MARK: - Mocks

final class ActionTimerMock: ActionTimer {

    init() {}
    
    func executeAfter(_ interval: TimeInterval, block: @escaping () async -> Void) {
        Task {
            await block()
        }
    }
    
    func cancel() { }
}

final class ActionTimerFactoryMock: ActionTimerFactory {
    
    func create() -> ActionTimer {
        return ActionTimerMock()
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
        
        guard currentIndex < timeMarks.count else {
            return nil
        }
        
        return timeMarks[currentIndex]
    }
    
    func next() -> TimeInterval? {
        
        guard let next = getNext() else {
            return nil
        }

        currentIndex += 1
        return next
    }
    
}
