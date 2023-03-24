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
            
            let time = sut.getTimeOfNextEvent()
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
                .init(index: 0, timeRange: 0..<5),
                .init(index: 1, timeRange: 5..<10, subtitlesPosition: .sentence(1))
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
                .init(index: 0, timeRange: 0..<5),
                .init(index: 1, timeRange: 5..<10, subtitlesPosition: .sentence(1))
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
                .init(index: 0, timeRange: 0..<5),
                .init(index: 1, timeRange: 5..<10, subtitlesPosition: .sentence(1))
            ],
            expectedItems: [
                10,
                nil
            ]
        )
    }
}
