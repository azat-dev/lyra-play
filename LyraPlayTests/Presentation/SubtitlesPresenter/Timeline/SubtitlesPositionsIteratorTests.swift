//
//  SubtitlesPositionsIterator.swift
//  LyraPlayTests
//
//  Created by Azat Kaiumov on 04.08.22.
//

import Foundation
import XCTest

import LyraPlay

class SubtitlesPositionsIteratorTests: XCTestCase {
    
    typealias SUT = SubtitlesPositionsIterator
    
    func createSUT(subtitles: Subtitles) -> SUT {
        
        let iterator = SubtitlesPositionsIterator(subtitles: subtitles)
        detectMemoryLeak(instance: iterator)
        
        return iterator
    }
    
    private func anySentence(at: TimeInterval, duration: TimeInterval? = nil, timeMarks: [Subtitles.TimeMark]? = nil) -> Subtitles.Sentence {
        
        return .init(
            startTime: at,
            duration: duration,
            text: "",
            timeMarks: timeMarks,
            components: []
        )
    }
    
    private func anyTimeMark(at: TimeInterval, duration: TimeInterval? = nil) -> Subtitles.TimeMark {
        
        let dummyRange = "a".range(of: "a")!
        
        return .init(
            startTime: at,
            duration: duration,
            range: dummyRange
        )
    }
    
    func testSubtitles(
        subtitles: Subtitles,
        expectedItems: [ExpectedSubtitlesPosition],
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        
        let sut = createSUT(subtitles: subtitles)
        
        var receivedItems = [ExpectedSubtitlesPosition]()
        
        var lastPosition: SubtitlesPosition? = nil
        
        while true {
            
            let nextPosition = sut.next(from: lastPosition)
            receivedItems.append(.init(from: nextPosition))
            
            lastPosition = nextPosition
            
            if nextPosition == nil {
                break
            }
        }
        
        AssertEqualReadable(receivedItems, expectedItems)
    }
    
    func test_next__empty_subtitles() async throws {
        
        let emptySubtitles = Subtitles(duration: 0, sentences: [])
        testSubtitles(subtitles: emptySubtitles, expectedItems: [.nilValue()])
    }
    
    func test_next__simple_sentences() async throws {
        
        let subtitles = Subtitles(duration: 10, sentences: [
            
            anySentence(at: 0),
            anySentence(at: 1)
        ])
        
        testSubtitles(
            subtitles: subtitles,
            expectedItems: [
                .sentence(0),
                .sentence(1),
                .nilValue()
            ]
        )
    }
    
    func test_next__time_mark_has_same_startTime_as_sentence() {
        
        let subtitles = Subtitles(duration: 10, sentences: [
            anySentence(at: 0, timeMarks: [
                anyTimeMark(at: 0)
            ]),
        ])
        
        testSubtitles(
            subtitles: subtitles,
            expectedItems: [
                .init(sentenceIndex: 0, timeMarkIndex: 0),
                .nilValue()
            ]
        )
    }
    
    func test_next__time_mark_has_different_startTime_from_sentence() {
        
        let subtitles = Subtitles(duration: 10, sentences: [
            anySentence(at: 0, timeMarks: [
                anyTimeMark(at: 1)
            ]),
        ])
        
        testSubtitles(
            subtitles: subtitles,
            expectedItems: [
                .init(sentenceIndex: 0, timeMarkIndex: nil),
                .init(sentenceIndex: 0, timeMarkIndex: 0),
                .nilValue()
            ]
        )
    }
    
    func test_next__multiple_time_marks() {
        
        let subtitles = Subtitles(duration: 10, sentences: [
            anySentence(at: 0, timeMarks: [
                anyTimeMark(at: 1),
                anyTimeMark(at: 2)
            ]),
        ])
        
        testSubtitles(
            subtitles: subtitles,
            expectedItems: [
                .init(sentenceIndex: 0, timeMarkIndex: nil),
                .init(sentenceIndex: 0, timeMarkIndex: 0),
                .init(sentenceIndex: 0, timeMarkIndex: 1),
                .nilValue()
            ]
        )
    }
    
    func test_getItem__sentences_without_time_marks() async throws {
        
        let subtitles = Subtitles(duration: 10, sentences: [
            anySentence(at: 1),
            anySentence(at: 2)
        ])
        let sut = createSUT(subtitles: subtitles)
        
        let item = sut.getItem(position: .init(sentenceIndex: 0, timeMarkIndex: nil))
        
        XCTAssertEqual(item.sentenceIndex.startTime, 1)
        XCTAssertNil(item.timeMarkInsideSentence)
    }
    
    func test_getItem__sentences_with_time_marks() async throws {
        
        let subtitles = Subtitles(duration: 10, sentences: [
            anySentence(at: 0),
            anySentence(at: 1, timeMarks: [
                anyTimeMark(at: 1),
                anyTimeMark(at: 2),
            ])
        ])
        let sut = createSUT(subtitles: subtitles)
        
        let item = sut.getItem(position: .init(sentenceIndex: 1, timeMarkIndex: 1))
        
        XCTAssertEqual(item.sentenceIndex.startTime, 1)
        XCTAssertEqual(item.timeMarkInsideSentence?.startTime, 2)
    }
}
