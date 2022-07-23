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
        
        return Subtitles(sentences: [
            anySentence(at: 0.0),
            anySentence(at: 1.0),
            anySentence(
                at: 2.0,
                timeMarks: [
                    .init(startTime: 2.0, range: dummyRange),
                    .init(startTime: 2.2, range: dummyRange)
                ]
            ),
            anySentence(at: 3.0)
        ])
    }
    
    func testMoveToTheMostRecentPositionInEmptyList() async throws {
        
        let subtitles = Subtitles(sentences: [])
        let sut = createSUT(subtitles: subtitles)
        
        let result = sut.move(at: 10)
        XCTAssertNil(result)
    }
    
    func testMoveToTheMostRecentSentenceNotEmptyList() async throws {
        
        let subtitles = getTestSubtitles()
        let sut = createSUT(subtitles: subtitles)
        
        let timeMarks = [0.0, 0.5, 1.0, 1.5, 2.0, 2.5, 3.0, 3.5, 4.0]
        let indexSequence = expectSequence([0, 0, 1, 1, 2, 2, 3, 3, 3] as [Int?])
        
        for timeMark in timeMarks {
            
            let success = sut.move(at: timeMark)
            XCTAssertNotNil(success)
            
            indexSequence.fulfill(with: sut.currentPosition?.sentenceIndex)
        }
        
        indexSequence.wait(timeout: 3, enforceOrder: true)
    }
    
    func testMoveToTheMostRecentWordNotSyncSentence() async throws {
        
        let subtitles = Subtitles(sentences: [
            anySentence(at: 0.0),
            anySentence(at: 1.0),
            anySentence(at: 2.0),
        ])
        
        let sentenceIndex = 1
        let sentence = subtitles.sentences[sentenceIndex]
        
        let sut = createSUT(subtitles: subtitles)
        
        let _ = sut.move(at: sentence.startTime - 1.0)
        XCTAssertNil(sut.currentPosition?.timeMarkIndex)
        
        let _ = sut.move(at: sentence.startTime)
        XCTAssertNil(sut.currentPosition?.timeMarkIndex)
        
        let _ = sut.move(at: sentence.startTime + 1)
        XCTAssertNil(sut.currentPosition?.timeMarkIndex)
    }
    
    func testMoveToTheMostRecentWordSyncSentence() async throws {
        
        let expectedSentences: [Subtitles.Sentence] = [
            anySentence(at: 0.0),
            anySentence(
                at: 1.0,
                timeMarks: [
                    timeMark(at: 1.1),
                    timeMark(at: 1.2)
                ]
            ),
            anySentence(at: 2.0)
        ]
        
        let subtitles = Subtitles(sentences: expectedSentences)
        
        let sentenceIndex = 1
        let targetSentence = subtitles.sentences[sentenceIndex]
        
        let sut = createSUT(subtitles: subtitles)
        
        let _ = sut.move(at: targetSentence.startTime - 0.5)
        XCTAssertEqual(sut.currentPosition?.sentenceIndex, 0)
        XCTAssertNil(sut.currentPosition?.timeMarkIndex)
        
        let _ = sut.move(at: targetSentence.startTime)
        XCTAssertEqual(sut.currentPosition?.sentenceIndex, 1)
        XCTAssertNil(sut.currentPosition?.timeMarkIndex)
        
        let _ = sut.move(at: targetSentence.startTime + 0.1)
        XCTAssertEqual(sut.currentPosition?.sentenceIndex, 1)
        XCTAssertEqual(sut.currentPosition?.timeMarkIndex, 0)
        
        let _ = sut.move(at: targetSentence.startTime + 0.15)
        XCTAssertEqual(sut.currentPosition?.sentenceIndex, 1)
        XCTAssertEqual(sut.currentPosition?.timeMarkIndex, 0)
        
        let _ = sut.move(at: targetSentence.startTime + 0.2)
        XCTAssertEqual(sut.currentPosition?.sentenceIndex, 1)
        XCTAssertEqual(sut.currentPosition?.timeMarkIndex, 1)
        
        let _ = sut.move(at: targetSentence.startTime + 100)
        XCTAssertEqual(sut.currentPosition?.sentenceIndex, 2)
        XCTAssertEqual(sut.currentPosition?.timeMarkIndex, nil)
    }
    
    func test_getNext_InEmptyList() async throws {
 
        let subtitles = Subtitles(sentences: [])
        let sut = createSUT(subtitles: subtitles)
        
        let result = sut.getNext()
        XCTAssertNil(result)
    }
    
    func test_getNext_returnNextSentenceIfNoWords() {
        
        let expectedSentences: [Subtitles.Sentence] = [
            anySentence(at: 0.0),
            anySentence(at: 1),
            anySentence(at: 2, timeMarks: []),
            anySentence(at: 3, timeMarks: []),
        ]
        
        let subtitles = Subtitles(sentences: expectedSentences)
        
        
        let sut = createSUT(subtitles: subtitles)
        
        let sequence = expectSequence([
            [0.0, 0, nil],
            [1, 1, nil],
            [2.0, 2, nil],
            [3.0, 3, nil],
            nil
        ])

        while !sequence.isCompleted {
            
            guard let time = sut.next() else {
                sequence.fulfill(with: nil)
                break
            }

            sequence.fulfill(with: [
                time,
                sut.currentPosition?.sentenceIndex.double,
                sut.currentPosition?.timeMarkIndex?.double
            ])
        }

        sequence.wait(timeout: 1, enforceOrder: true)
    }
    
    func test_getNext_receiveEmptyFirstWordIfTimeDoesntMatch() {
        
        let subtitles = Subtitles(sentences: [
            anySentence(
                at: 0,
                timeMarks: [
                    timeMark(at: 1)
                ]
            ),
        ])
        
        let sut = createSUT(subtitles: subtitles)
        
        let sequence = expectSequence([
            [0.0, 0, nil],
            [1.0, 0, 0],
            nil
        ])

        while !sequence.isCompleted {
            
            guard let time = sut.next() else {
                sequence.fulfill(with: nil)
                break
            }

            sequence.fulfill(with: [
                time,
                sut.currentPosition?.sentenceIndex.double,
                sut.currentPosition?.timeMarkIndex?.double
            ])
        }

        sequence.wait(timeout: 1, enforceOrder: true)
    }

    func test_getNext_receiveFirstWordIfTimeMatch() {
        
        let subtitles = Subtitles(sentences: [
            anySentence(
                at: 1,
                timeMarks: [
                    timeMark(at: 1)
                ]
            ),
        ])
        
        let sut = createSUT(subtitles: subtitles)
        
        let sequence = expectSequence([
            [1.0, 0, 0] as [Double?],
            nil
        ])

        while !sequence.isCompleted {
            
            guard let time = sut.next() else {
                sequence.fulfill(with: nil)
                break
            }

            sequence.fulfill(with: [
                time,
                sut.currentPosition?.sentenceIndex.double,
                sut.currentPosition?.timeMarkIndex?.double
            ])
        }

        sequence.wait(timeout: 1, enforceOrder: true)
    }
    
    func test_getNext_IterateOverSyncedWords() {
        
        let subtitles = Subtitles(sentences: [
            anySentence(
                at: 1,
                timeMarks: [
                    timeMark(at: 1),
                    timeMark(at: 1.5),
                ]
            ),
            anySentence(
                at: 2,
                timeMarks: [
                    timeMark(at: 2.1)
                ]
            ),
        ])
        
        let sut = createSUT(subtitles: subtitles)
        
        let sequence = expectSequence([
            [1.0, 0, 0],
            [1.5, 0, 1],
            [2.0, 1, nil],
            [2.1, 1, 0],
            nil
        ])

        while !sequence.isCompleted {
            
            guard let time = sut.next() else {
                sequence.fulfill(with: nil)
                break
            }

            sequence.fulfill(with: [
                time,
                sut.currentPosition?.sentenceIndex.double,
                sut.currentPosition?.timeMarkIndex?.double
            ])
        }

        sequence.wait(timeout: 1, enforceOrder: true)
    }
}
