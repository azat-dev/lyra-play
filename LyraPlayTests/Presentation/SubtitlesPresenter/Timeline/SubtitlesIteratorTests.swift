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
    
    private func notSyncedSentence(at: TimeInterval) -> Subtitles.Sentence {
        return Subtitles.Sentence(
            startTime: at,
            duration: 0,
            text: .notSynced(text: "")
        )
    }
    
    private func syncItem(at: TimeInterval) -> Subtitles.SyncedItem {
        return .init(
            startTime: at,
            duration: 0,
            text: ""
        )
    }
    
    private func syncItems(_ startingTimes: [TimeInterval]) -> [Subtitles.SyncedItem] {
        return startingTimes.map { syncItem(at: $0) }
    }
    
    func getTestSubtitles() -> Subtitles {
        
        return Subtitles(sentences: [
            notSyncedSentence(at: 0.0),
            notSyncedSentence(at: 1.0),
            Subtitles.Sentence(
                startTime: 2.0,
                duration: 0,
                text: .synced(items: [
                    Subtitles.SyncedItem(startTime: 2.0, duration: 0, text: ""),
                    Subtitles.SyncedItem(startTime: 2.2, duration: 0, text: "")
                ])
            ),
            Subtitles.Sentence(
                startTime: 3.0,
                duration: 0,
                text: .synced(items: [])
            )
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
            
            indexSequence.fulfill(with: sut.currentPosition?.sentence)
        }
        
        indexSequence.wait(timeout: 3, enforceOrder: true)
    }
    
    func testMoveToTheMostRecentWordNotSyncSentence() async throws {
        
        let subtitles = Subtitles(sentences: [
            notSyncedSentence(at: 0.0),
            notSyncedSentence(at: 1.0),
            notSyncedSentence(at: 2.0),
        ])
        
        let sentenceIndex = 1
        let sentence = subtitles.sentences[sentenceIndex]
        
        let sut = createSUT(subtitles: subtitles)
        
        let _ = sut.move(at: sentence.startTime - 1.0)
        XCTAssertNil(sut.currentPosition?.word)
        
        let _ = sut.move(at: sentence.startTime)
        XCTAssertNil(sut.currentPosition?.word)
        
        let _ = sut.move(at: sentence.startTime + 1)
        XCTAssertNil(sut.currentPosition?.word)
    }
    
    func testMoveToTheMostRecentWordSyncSentence() async throws {
        
        let subtitles = Subtitles(sentences: [
            notSyncedSentence(at: 0.0),
            Subtitles.Sentence(
                startTime: 1.0,
                duration: 0,
                text: .synced(items: syncItems([1.1, 1.2]))
            ),
            notSyncedSentence(at: 2.0),
        ])
        
        let sentenceIndex = 1
        let targetSentence = subtitles.sentences[sentenceIndex]
        
        let sut = createSUT(subtitles: subtitles)
        
        let _ = sut.move(at: targetSentence.startTime - 0.5)
        XCTAssertEqual(sut.currentPosition?.sentence, 0)
        XCTAssertNil(sut.currentPosition?.word)
        
        let _ = sut.move(at: targetSentence.startTime)
        XCTAssertEqual(sut.currentPosition?.sentence, 1)
        XCTAssertNil(sut.currentPosition?.word)
        
        let _ = sut.move(at: targetSentence.startTime + 0.1)
        XCTAssertEqual(sut.currentPosition?.sentence, 1)
        XCTAssertEqual(sut.currentPosition?.word, 0)
        
        let _ = sut.move(at: targetSentence.startTime + 0.15)
        XCTAssertEqual(sut.currentPosition?.sentence, 1)
        XCTAssertEqual(sut.currentPosition?.word, 0)
        
        let _ = sut.move(at: targetSentence.startTime + 0.2)
        XCTAssertEqual(sut.currentPosition?.sentence, 1)
        XCTAssertEqual(sut.currentPosition?.word, 1)
        
        let _ = sut.move(at: targetSentence.startTime + 100)
        XCTAssertEqual(sut.currentPosition?.sentence, 2)
        XCTAssertEqual(sut.currentPosition?.word, nil)
    }
    
    func test_getNext_InEmptyList() async throws {
 
        let subtitles = Subtitles(sentences: [])
        let sut = createSUT(subtitles: subtitles)
        
        let result = sut.getNext()
        XCTAssertNil(result)
    }
    
    func test_getNext_returnNextSentenceIfNoWords() {
        
        let subtitles = Subtitles(sentences: [
            notSyncedSentence(at: 0),
            notSyncedSentence(at: 1),
            Subtitles.Sentence(
                startTime: 2,
                duration: 0,
                text: .synced(items: [])
            ),
            Subtitles.Sentence(
                startTime: 3,
                duration: 0,
                text: .synced(items: [])
            )
        ])
        
        
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
                sut.currentPosition?.sentence.double,
                sut.currentPosition?.word?.double
            ])
        }

        sequence.wait(timeout: 1, enforceOrder: true)
    }
    
    func test_getNext_receiveEmptyFirstWordIfTimeDoesntMatch() {
        
        let subtitles = Subtitles(sentences: [
            Subtitles.Sentence(
                startTime: 0,
                duration: 0,
                text: .synced(items: syncItems([1]))
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
                sut.currentPosition?.sentence.double,
                sut.currentPosition?.word?.double
            ])
        }

        sequence.wait(timeout: 1, enforceOrder: true)
    }

    func test_getNext_receiveFirstWordIfTimeMatch() {
        
        let subtitles = Subtitles(sentences: [
            Subtitles.Sentence(
                startTime: 1,
                duration: 0,
                text: .synced(items: syncItems([1]))
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
                sut.currentPosition?.sentence.double,
                sut.currentPosition?.word?.double
            ])
        }

        sequence.wait(timeout: 1, enforceOrder: true)
    }
    
    func test_getNext_IterateOverSyncedWords() {
        
        let subtitles = Subtitles(sentences: [
            Subtitles.Sentence(
                startTime: 1,
                duration: 0,
                text: .synced(items: syncItems([1, 1.5]))
            ),
            Subtitles.Sentence(
                startTime: 2,
                duration: 0,
                text: .synced(items: syncItems([2.1]))
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
                sut.currentPosition?.sentence.double,
                sut.currentPosition?.word?.double
            ])
        }

        sequence.wait(timeout: 1, enforceOrder: true)
    }
}