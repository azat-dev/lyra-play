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

    func createSUT(subtitles: Subtitles) -> SUT {

        let timeSlotsParser = SubtitlesTimeSlotsParser()
        
        let subtitlesIterator = DefaultSubtitlesIterator(
            subtitles: subtitles,
            subtitlesTimeSlots: timeSlotsParser.parse(from: subtitles)
        )
        detectMemoryLeak(instance: subtitlesIterator)

        return subtitlesIterator
    }

    private func anySentence(at: TimeInterval, timeMarks: [Subtitles.TimeMark]? = nil) -> Subtitles.Sentence {
        return Subtitles.Sentence(
            startTime: at,
            duration: nil,
            text: "",
            timeMarks: timeMarks,
            components: []
        )
    }

    private func timeMark(at: TimeInterval) -> Subtitles.TimeMark {

        let text = ""
        let dummyRange = (text.startIndex..<text.endIndex)

        return .init(
            startTime: at,
            duration: nil,
            range: dummyRange
        )
    }

    func getTestSubtitles() -> Subtitles {

        let dummyText = ""
        let dummyRange = (dummyText.startIndex..<dummyText.endIndex)

        return Subtitles(
            duration: 3.5,
            sentences: [
                anySentence(at: 0.0),
                anySentence(at: 2.0),
                anySentence(
                    at: 3.0,
                    timeMarks: [
                        .init(startTime: 3.0, range: dummyRange),
                        .init(startTime: 3.2, range: dummyRange)
                    ]
                ),
                anySentence(
                    at: 3.0,
                    timeMarks: [
                        .init(startTime: 3.1, range: dummyRange)
                    ]
                )
            ]
        )
    }
    
    func test_getTimeOfNextEvent(
        subtitles: Subtitles,
        expectedItems: [TimeInterval?],
        file: StaticString = #filePath,
        line: UInt = #line
    ) {

        let sut = createSUT(subtitles: subtitles)
        var receivedItems = [TimeInterval?]()
        
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
    
    func test_getTimeOfNextEvent__with_empty_subtitle() async throws {

        let subtitles = Subtitles(duration: 0, sentences: [])
        test_getTimeOfNextEvent(
            subtitles: subtitles,
            expectedItems: [
                0,
                nil
            ]
        )
    }
    
    func test_getTimeOfNextEvent__receive_end_time_at_the_end() async throws {
        
        let subtitles = Subtitles(duration: 10, sentences: [])
        test_getTimeOfNextEvent(
            subtitles: subtitles,
            expectedItems: [
                0,
                10,
                nil
            ]
        )
    }
    
    func test_getTimeOfNextEvent__not_empty_subtitles() async throws {

        let subtitles = Subtitles(duration: 10, sentences: [
            anySentence(at: 1),
        ])
        let sut = createSUT(subtitles: subtitles)

        let prevState = ExpectedSubtitlesIteratorOutput(from: sut)
        let result = sut.getTimeOfNextEvent()
        
        XCTAssertEqual(result, 0)
        AssertEqualReadable(.init(from: sut), prevState)
    }
    
    func test_moveToNextEvent(
        subtitles: Subtitles,
        expectedItems: [ExpectedSubtitlesIteratorOutput],
        file: StaticString = #filePath,
        line: UInt = #line
    ) {

        let sut = createSUT(subtitles: subtitles)
        var receivedItems = [ExpectedSubtitlesIteratorOutput]()
        
        while true {
            
            let item = sut.moveToNextEvent()
            receivedItems.append(.init(from: sut))
            
            if item == nil {
                break
            }
        }
        
        AssertEqualReadable(receivedItems, expectedItems, file: file, line: line)
    }
    
    func test_moveToNextEvent__with_empty_subtitles() async throws {

        let subtitles = Subtitles(duration: 0, sentences: [])
        test_moveToNextEvent(
            subtitles: subtitles,
            expectedItems: [
                .init(time: 0, timeRange: (0..<0)),
                .init(time: nil)
            ]
        )
    }
    
    func test_moveToNextEvent__with_simple_subtitles() async throws {

        let subtitles = Subtitles(duration: 3, sentences: [
            anySentence(at: 1),
            anySentence(at: 2),
        ])
        
        test_moveToNextEvent(
            subtitles: subtitles,
            expectedItems: [
                .init(
                    time: 0,
                    timeRange: (0..<1),
                    position: .nilValue()
                ),
                .init(
                    time: 1,
                    timeRange: (1..<2),
                    position: .sentence(0)
                ),
                .init(
                    time: 2,
                    timeRange: (2..<3),
                    position: .sentence(1)
                ),
                .init(time: 3),
                .init(time: nil)
            ]
        )
    }
    
    func test_beginNextExecution__empty_subtitles() {
        
        let subtitles = Subtitles(duration: 0, sentences: [])
        
        let sut = createSUT(subtitles: subtitles)
        let _ = sut.beginNextExecution(from: 0)
        
        let expectedResult = ExpectedSubtitlesIteratorOutput(time: 0, timeRange: (0..<0))
        AssertEqualReadable(.init(from: sut), expectedResult)
    }
    
    func test_beginNextExecution__empty_subtitles_with_offset() {
        
        let subtitles = Subtitles(duration: 0, sentences: [])
        
        let sut = createSUT(subtitles: subtitles)
        let _ = sut.beginNextExecution(from: 100)
        
        let expectedResult = ExpectedSubtitlesIteratorOutput(time: 0, timeRange: (0..<0))
        AssertEqualReadable(.init(from: sut), expectedResult)
    }
    
    func test_beginNextExecution__not_empty_subtitles_exact_time_match() {
        
        let subtitles = Subtitles(duration: 10, sentences: [
            anySentence(at: 0),
            anySentence(at: 1),
            anySentence(at: 2),
        ])
        
        let sut = createSUT(subtitles: subtitles)
        let _ = sut.beginNextExecution(from: 1.5)
        
        let expectedResult = ExpectedSubtitlesIteratorOutput(
            time: 1,
            timeRange: (1..<2),
            position: .sentence(1)
        )
        AssertEqualReadable(.init(from: sut), expectedResult)
    }
    
    func test_beginNextExecution__not_empty_subtitles_between() {
        
        let subtitles = Subtitles(duration: 10, sentences: [
            anySentence(at: 0),
            anySentence(at: 1),
            anySentence(at: 2),
        ])
        
        let sut = createSUT(subtitles: subtitles)
        let _ = sut.beginNextExecution(from: 1.5)
        
        let expectedResult = ExpectedSubtitlesIteratorOutput(
            time: 1,
            timeRange: (1..<2),
            position: .sentence(1)
        )
        AssertEqualReadable(.init(from: sut), expectedResult)
    }
    
    func test_beginNextExecution__not_empty_subtitles_end() {
        
        let subtitles = Subtitles(duration: 10, sentences: [
            anySentence(at: 0),
            anySentence(at: 1),
            anySentence(at: 2),
        ])
        
        let sut = createSUT(subtitles: subtitles)
        let _ = sut.beginNextExecution(from: 10)
        
        let expectedResult = ExpectedSubtitlesIteratorOutput(
            time: 10,
            timeRange: nil
        )
        AssertEqualReadable(.init(from: sut), expectedResult)
    }
}

// MARK: - Helpers

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
