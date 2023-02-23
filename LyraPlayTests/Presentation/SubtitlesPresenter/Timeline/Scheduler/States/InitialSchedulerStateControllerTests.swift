//
//  InitialSchedulerStateControllerTests.swift
//  LyraPlayTests
//
//  Created by Azat Kaiumov on 23.02.23.
//

import Foundation
import XCTest
import LyraPlay
import Mockingbird

class InitialSchedulerStateControllerTests: XCTestCase {
    
    typealias SUT = (
        controller: InitialSchedulerStateController,
        timer: ActionTimerMock,
        timeline: TimeLineIteratorMock,
        delegate: TimelineSchedulerStateControllerDelegateMock,
        delegateChanges: TimelineSchedulerDelegateChanges
    )
    
    func createSUT() -> SUT {
        
        let timer = mock(ActionTimer.self)
        let timeline = mock(TimeLineIterator.self)
        
        let delegate = mock(TimelineSchedulerStateControllerDelegate.self)
        let delegateChanges = mock(TimelineSchedulerDelegateChanges.self)
        
        let controller = InitialSchedulerStateController(
            timer: timer,
            timeline: timeline,
            delegate: delegate,
            delegateChanges: delegateChanges
        )
        detectMemoryLeak(instance: controller)
        
        return (
            controller,
            timer,
            timeline,
            delegate,
            delegateChanges
        )
    }
    
    
    func test_run() async throws {
        
        let sut = createSUT()
        
        // Given
        
        // When
        sut.controller.run()
        
        // Then
        verify(sut.timer.cancel())
            .wasCalled(1)
    }
    
    func test_execute() async throws {
        
        let sut = createSUT()
        
        // Given
        let starTime: TimeInterval = 5

        // When
        sut.controller.execute(from: starTime)
        
        // Then
        
        verify(
            sut.delegate.execute(
                timer: sut.timer,
                timeline: sut.timeline,
                from: starTime,
                delegateChanges: sut.delegateChanges
            )
        ).wasCalled(1)
    }
}

