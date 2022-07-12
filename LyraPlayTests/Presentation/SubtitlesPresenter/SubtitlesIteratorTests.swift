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
        
        let result = sut.move(to: 10)
        XCTAssertNil(result)
    }
    
    func testMoveToTheMostRecentSentenceNotEmptyList() async throws {
        
        let subtitles = getTestSubtitles()
        let sut = createSUT(subtitles: subtitles)
        
        let timeMarks = [0.0, 0.5, 1.0, 1.5, 2.0, 2.5, 3.0, 3.5, 4.0]
        let indexSequence = expectSequence([0, 0, 1, 1, 2, 2, 3, 3, 3] as [Int?])
        
        for timeMark in timeMarks {
            
            let result = sut.move(to: timeMark)
            
            indexSequence.fulfill(with: result?.sentence)
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
        
        let result1 = sut.move(to: sentence.startTime - 1.0)
        XCTAssertNil(result1?.word)
        
        let result2 = sut.move(to: sentence.startTime)
        XCTAssertNil(result2?.word)
        
        let result3 = sut.move(to: sentence.startTime + 1)
        XCTAssertNil(result3?.word)
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
        
        let result1 = sut.move(to: targetSentence.startTime - 0.5)
        XCTAssertEqual(result1?.sentence, 0)
        XCTAssertNil(result1?.word)
        
        let result2 = sut.move(to: targetSentence.startTime)
        XCTAssertEqual(result2?.sentence, 1)
        XCTAssertNil(result2?.word)
        
        let result3 = sut.move(to: targetSentence.startTime + 0.1)
        XCTAssertEqual(result3?.sentence, 1)
        XCTAssertEqual(result3?.word, 0)
        
        let result4 = sut.move(to: targetSentence.startTime + 0.15)
        XCTAssertEqual(result4?.sentence, 1)
        XCTAssertEqual(result4?.word, 0)
        
        let result5 = sut.move(to: targetSentence.startTime + 0.2)
        XCTAssertEqual(result5?.sentence, 1)
        XCTAssertEqual(result5?.word, 1)
        
        let result6 = sut.move(to: targetSentence.startTime + 100)
        XCTAssertEqual(result6?.sentence, 2)
        XCTAssertEqual(result6?.word, nil)
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
            [0, nil],
            [1, nil],
            [2, nil],
            [3, nil],
            nil
        ])

        while !sequence.isCompleted {
            
            let result = sut.next()
            
            guard let result = result else {
                sequence.fulfill(with: nil)
                break
            }

            sequence.fulfill(with: [result.sentence, result.word])
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
            [0, nil],
            [0, 0],
            nil
        ])

        while !sequence.isCompleted {
            
            let result = sut.next()
            
            guard let result = result else {
                sequence.fulfill(with: nil)
                break
            }

            sequence.fulfill(with: [result.sentence, result.word])
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
            [0, 0] as [Int?],
            nil
        ])

        while !sequence.isCompleted {
            
            let result = sut.next()
            
            guard let result = result else {
                sequence.fulfill(with: nil)
                break
            }

            sequence.fulfill(with: [result.sentence, result.word])
        }

        sequence.wait(timeout: 1, enforceOrder: true)
    }
    
    func test_getNext_IterateOverSyncedWords() {
        
        let subtitles = Subtitles(sentences: [
            Subtitles.Sentence(
                startTime: 1,
                duration: 0,
                text: .synced(items: syncItems([1, 2]))
            ),
            Subtitles.Sentence(
                startTime: 2,
                duration: 0,
                text: .synced(items: syncItems([2.1]))
            ),
        ])
        
        let sut = createSUT(subtitles: subtitles)
        
        let sequence = expectSequence([
            [0, 0],
            [0, 1],
            [1, nil],
            [1, 0],
            nil
        ])

        while !sequence.isCompleted {
            
            let result = sut.next()
            
            guard let result = result else {
                sequence.fulfill(with: nil)
                break
            }

            sequence.fulfill(with: [result.sentence, result.word])
        }

        sequence.wait(timeout: 1, enforceOrder: true)
    }
}
