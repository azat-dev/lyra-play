//
//  RunningSchedulerStateControllerTests.swift
//  LyraPlayTests
//
//  Created by Azat Kaiumov on 23.02.23.
//

import Foundation

import Foundation
import XCTest
import LyraPlay
import Mockingbird

class RunningSchedulerStateControllerTests: XCTestCase {
    
    typealias SUT = (
        controller: RunningSchedulerStateController,
        timer: ActionTimerMock,
        timeline: TimeLineIteratorMock,
        delegate: TimelineSchedulerStateControllerDelegateMock,
        delegateChanges: TimelineSchedulerDelegateChanges
    )
    
    func createSUT() -> SUT {
        
        let timer = mock(ActionTimer.self)
        
        given(timer.executeAfter(any(), block: any()))
            .will { _, callback in
                Task {
                    await callback()
                }
            }
        
        let timeline = mock(TimeLineIterator.self)
        
        let delegate = mock(TimelineSchedulerStateControllerDelegate.self)
        let delegateChanges = mock(TimelineSchedulerDelegateChanges.self)
        
        let controller = RunningSchedulerStateController(
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
    
    func test_pause() async throws {
        
        let sut = createSUT()
        
        // Given
        let startTime: TimeInterval = 5
        
        given(sut.timeline.getTimeOfNextEvent())
            .willReturn(nil)
        
        // When
        sut.controller.runExecution(from: startTime)
        sut.controller.pause()
        
        // Then
        verify(
            sut.delegate.pause(
                elapsedTime: any(),
                timer: sut.timer,
                timeline: sut.timeline,
                delegateChanges: sut.delegateChanges
            )
        ).wasCalled(1)
        
        verify(
            sut.delegate.execute(
                timer: any(),
                timeline: any(),
                from: any(),
                delegateChanges: any()
            )
        ).wasNeverCalled()
    }
    
    func test_execute__no_events() async throws {
        
        let sut = createSUT()
        
        // Given
        let startTime: TimeInterval = 5
        
        given(sut.timeline.getTimeOfNextEvent())
            .willReturn(nil)
        
        // When
        sut.controller.runExecution(from: startTime)
        
        // Then
        verify(sut.delegate.didFinish())
            .wasCalled(1)
        
        verify(
            sut.delegate.execute(
                timer: any(),
                timeline: any(),
                from: any(),
                delegateChanges: any()
            )
        ).wasNeverCalled()
    }
    
    func test_execute__from_start() async throws {
        
        let sut = createSUT()
        
        // Given
        let startTime: TimeInterval = 0
        
        given(sut.timeline.getTimeOfNextEvent())
            .willReturn(0)
            .willReturn(nil)
        
        // When
        sut.controller.runExecution(from: startTime)
        
        // Then
        
        inOrder {
            
            var stop = false
            
            verify(sut.delegate.didStartExecuting(withController: any()))
                .wasCalled(1)
            
            verify(sut.delegateChanges.schedulerWillChange(from: nil, to: startTime, stop: &stop))
                .wasCalled(1)
            
            verify(sut.delegateChanges.schedulerDidChange(time: startTime))
                .wasCalled(1)
            
            verify(sut.delegate.didFinish())
                .wasCalled(1)
            
            verify(sut.delegateChanges.schedulerDidFinish())
                .wasCalled(1)

        }
    }
    
    func test_execute__from_middle() async throws {
        
        let sut = createSUT()
        
        // Given
        let startTime: TimeInterval = 1
        let timemarks: [TimeInterval] = [0, 2, 4]
        
        let getTimeOfNextEventPromise = given(sut.timeline.getTimeOfNextEvent())
        
        timemarks.forEach { time in
            getTimeOfNextEventPromise.willReturn(time)
        }
        
        // When
        sut.controller.runExecution(from: startTime)
        
        // Then
        eventually {
            inOrder {
                
                var lastTime: TimeInterval? = nil
                
                timemarks
                    .filter { $0 >= startTime }
                    .forEach { time in
                        
                        var stop = false
                        verify(
                            sut.delegateChanges.schedulerWillChange(
                                from: lastTime,
                                to: time,
                                stop: &stop
                            )
                        ).wasCalled(1)
                        
                        verify(
                            sut.delegateChanges.schedulerDidChange(time: time)
                        ).wasCalled(1)
                        
                        lastTime = time
                    }
                
                verify(sut.delegateChanges.schedulerDidFinish())
                    .wasCalled(1)
            }
        }
        
        await waitForExpectations(timeout: 1)
    }
}

