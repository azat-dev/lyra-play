//
//  SubtitlesIteratorTests.swift
//  LyraPlayTests
//
//  Created by Azat Kaiumov on 11.07.22.
//

import Foundation
import XCTest
import LyraPlay

class SubtitlesIteratorTests: XCTestCase {
    
    typealias SUT = SubtitlesIterator
    
    func createSUT(timeSlots: [SubtitlesTimeSlot]) -> SUT {
        
        let subtitlesIterator = SubtitlesIteratorImpl(subtitlesTimeSlots: timeSlots)
        detectMemoryLeak(instance: subtitlesIterator)
        
        return subtitlesIterator
    }
    
    func testIteration(
        startTime: TimeInterval?,
        timeSlots: [SubtitlesTimeSlot],
        expectedItems: [TimeInterval?],
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        
        let sut = createSUT(timeSlots: timeSlots)
        var receivedItems = [TimeInterval?]()
        
        if let startTime = startTime {
            let _ = sut.beginNextExecution(from: startTime)
        }
        
        while true {
            
            let prevState = ExpectedSubtitlesIteratorOutput(from: sut)
            let time = sut.getTimeOfNextEvent()
            
            AssertEqualReadable(.init(from: sut), prevState)
            let _ = sut.moveToNextEvent()
            
            receivedItems.append(time)
            
            if time == nil {
                break
            }
        }
        
        AssertEqualReadable(receivedItems, expectedItems, file: file, line: line)
    }
    
    func test_iteration__empty() async throws {
        
        testIteration(
            startTime: nil,
            timeSlots: [],
            expectedItems: [
                0,
                nil
            ]
        )
    }
    
    func test_iteration__empty_with_offset() async throws {
        
        testIteration(
            startTime: 100,
            timeSlots: [],
            expectedItems: [
                0,
                nil
            ]
        )
    }
    
    func test_iteration__not_empty_without_offset() async throws {
        
        testIteration(
            startTime: nil,
            timeSlots: [
                .init(timeRange: 0..<5),
                .init(timeRange: 5..<10, subtitlesPosition: .sentence(1))
            ],
            expectedItems: [
                0,
                5,
                10,
                nil
            ]
        )
    }
    
    func test_iteration__not_empty_with_offset() async throws {
        
        testIteration(
            startTime: 5,
            timeSlots: [
                .init(timeRange: 0..<5),
                .init(timeRange: 5..<10, subtitlesPosition: .sentence(1))
            ],
            expectedItems: [
                5,
                10,
                nil
            ]
        )
        
        testIteration(
            startTime: 10,
            timeSlots: [
                .init(timeRange: 0..<5),
                .init(timeRange: 5..<10, subtitlesPosition: .sentence(1))
            ],
            expectedItems: [
                10,
                nil
            ]
        )
    }
}

struct ExpectedSubtitlesIteratorOutput: Equatable {
    
    var time: TimeInterval?
    var position: ExpectedSubtitlesPosition
    var timeRange: Range<TimeInterval>?
    
    init(
        time: TimeInterval?,
        timeRange: Range<TimeInterval>? = nil,
        position: ExpectedSubtitlesPosition = .nilValue()
    ) {
        
        self.time = time
        self.timeRange = timeRange
        self.position = position
    }
    
    init(from iterator: SubtitlesIterator) {
        
        time = iterator.lastEventTime
        timeRange = iterator.currentTimeRange
        position = .init(from: iterator.currentPosition)
    }
}
