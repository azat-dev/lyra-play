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

        let subtitlesIterator = DefaultSubtitlesIterator(
            subtitles: subtitles
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
    
    func test_getNext(
        subtitles: Subtitles,
        expectedItems: [TimeInterval?],
        file: StaticString = #filePath,
        line: UInt = #line
    ) {

        let sut = createSUT(subtitles: subtitles)
        var receivedItems = [TimeInterval?]()
        
        while true {
            
            let prevState = ExpectedSubtitlesIteratorOutput(from: sut)
            let time = sut.getNext()
            
            AssertEqualReadable(.init(from: sut), prevState)
            let _ = sut.next()
            
            
            receivedItems.append(time)
            
            if time == nil {
                break
            }
        }
        
        AssertEqualReadable(receivedItems, expectedItems, file: file, line: line)
    }
    
    func test_getNext__with_empty_subtitle() async throws {

        let subtitles = Subtitles(duration: 0, sentences: [])
        test_getNext(
            subtitles: subtitles,
            expectedItems: [
                0,
                nil
            ]
        )
    }
    
    func test_getNext__receive_end_time_at_the_end() async throws {
        
        let subtitles = Subtitles(duration: 10, sentences: [])
        test_getNext(
            subtitles: subtitles,
            expectedItems: [
                0,
                10,
                nil
            ]
        )
    }
    
    func test_getNext__not_empty_subtitles() async throws {

        let subtitles = Subtitles(duration: 10, sentences: [
            anySentence(at: 1),
        ])
        let sut = createSUT(subtitles: subtitles)

        let prevState = ExpectedSubtitlesIteratorOutput(from: sut)
        let result = sut.getNext()
        
        XCTAssertEqual(result, 0)
        AssertEqualReadable(.init(from: sut), prevState)
    }
    
    func test_next(
        subtitles: Subtitles,
        expectedItems: [ExpectedSubtitlesIteratorOutput],
        file: StaticString = #filePath,
        line: UInt = #line
    ) {

        let sut = createSUT(subtitles: subtitles)
        var receivedItems = [ExpectedSubtitlesIteratorOutput]()
        
        while true {
            
            let item = sut.next()
            receivedItems.append(.init(from: sut))
            
            if item == nil {
                break
            }
        }
        
        AssertEqualReadable(receivedItems, expectedItems, file: file, line: line)
    }
    
    func test_next__with_empty_subtitles() async throws {

        let subtitles = Subtitles(duration: 0, sentences: [])
        test_next(
            subtitles: subtitles,
            expectedItems: [
                .init(time: 0, timeRange: (0..<0)),
                .init(time: nil)
            ]
        )
    }
    
    func test_next__with_simple_subtitles() async throws {

        let subtitles = Subtitles(duration: 3, sentences: [
            anySentence(at: 1),
            anySentence(at: 2),
        ])
        
        test_next(
            subtitles: subtitles,
            expectedItems: [
                .init(
                    time: 0,
                    timeRange: (0..<1),
                    position: .init(isNil: true)
                ),
                .init(
                    time: 1,
                    timeRange: (1..<2),
                    position: .init(
                        isNil: false,
                        sentenceIndex: 0
                    )
                ),
                .init(
                    time: 2,
                    timeRange: (2..<3),
                    position: .init(
                        isNil: false,
                        sentenceIndex: 1
                    )
                ),
                .init(time: 3),
                .init(time: nil)
            ]
        )
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
        position: ExpectedSubtitlesPosition = .init(isNil: true)
    ) {
        
        self.time = time
        self.timeRange = timeRange
        self.position = position
    }
    
    init(from iterator: SubtitlesIterator) {

        time = iterator.currentTime
        timeRange = iterator.currentTimeRange
        position = .init(from: iterator.currentPosition)
    }
}
