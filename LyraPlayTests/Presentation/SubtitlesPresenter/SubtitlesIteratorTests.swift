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
    
    func notSyncedSentence(at: Double) -> Subtitles.Sentence {
        return Subtitles.Sentence(
            startTime: at,
            duration: 0,
            text: .notSynced(text: "")
        )
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
            
            indexSequence.fulfill(with: result.sentence?.index)
        }
        
        indexSequence.wait(timeout: 3, enforceOrder: true)
        sentenceSequence.wait(timeout: 3, enforceOrder: true)
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
        
        let result1 = sut.move(to: sentence.startTime - 1.0, in: sentenceIndex)
        XCTAssertNil(result1.word)
        
        let result2 = sut.move(to: sentence.startTime, in: sentenceIndex)
        XCTAssertNil(result2.word)
        
        let result3 = sut.move(to: sentence.startTime + 1, in: sentenceIndex)
        XCTAssertNil(result3.word)
    }
    
    func testMoveToTheMostRecentWordSyncSentence() async throws {
        
        let subtitles = Subtitles(sentences: [
            notSyncedSentence(at: 0.0),
            Subtitles.Sentence(
                startTime: 1.0,
                duration: 0,
                text: .synced(items: [
                    Subtitles.SyncedItem(
                        startTime: 1.1,
                        duration: 0,
                        text: ""
                    ),
                    Subtitles.SyncedItem(
                        startTime: 1.2,
                        duration: 0,
                        text: ""
                    ),
                    Subtitles.SyncedItem(
                        startTime: 1.3,
                        duration: 0,
                        text: ""
                    ),
                ])
            ),
            notSyncedSentence(at: 2.0),
        ])
        
        let sentenceIndex = 1
        let sentence = subtitles.sentences[sentenceIndex]
        
        let sut = createSUT(subtitles: subtitles)
        
        let result1 = sut.move(to: sentence.startTime - 1, in: sentenceIndex)
        XCTAssertNil(result1.word)
        
        let result2 = sut.move(to: sentence.startTime, in: sentenceIndex)
        XCTAssertNil(result2.word)
        
        let result3 = sut.move(to: sentence.startTime + 0.1, in: sentenceIndex)
        XCTAssertEqual(result3.word?.index, 0)
        
        let result4 = sut.move(to: sentence.startTime + 0.15, in: sentenceIndex)
        XCTAssertEqual(result4.word?.index, 0)
        
        let result5 = sut.move(to: sentence.startTime + 0.2, in: sentenceIndex)
        XCTAssertEqual(result5.word?.index, 1)
    }
//    
//    func testGetNextInEmptyList() async throws {
// 
//        let subtitles = Subtitles(sentences: [])
//        let sut = createSUT(subtitles: subtitles)
//        
//        let result = sut.getNext(from: 10)
//        XCTAssertNil(result)
//    }
//    
//    func testGetNextNotEmptyList() async throws {
// 
//        let subtitles = Subtitles(sentences: [
//            notSyncedSentence(at: 0),
//            notSyncedSentence(at: 1)
//        ])
//        let sut = createSUT(subtitles: subtitles)
//        
//        let result1 = sut.getNextSentence(from: 0)
//        XCTAssertEqual(result1?.index, 1)
//        
//        let result2 = sut.getNextSentence(from: 1)
//        XCTAssertNil(result2?.index)
//    }
}
