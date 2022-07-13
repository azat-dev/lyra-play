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
        timerFactory: ActionTimerFactory
    )
    
    func createSUT() -> SUT {
        
        let timerFactory = ActionTimerFactoryMock()
        let iterator = TimeMarksIteratorMock()
        
        let scheduler = DefaultScheduler(
            timeMarksIterator: iterator,
            actionTimerFactory: timerFactory
        )
        
        detectMemoryLeak(instance: scheduler)
        
        return (
            scheduler,
            iterator,
            timerFactory
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
