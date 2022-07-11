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
    
    func testSearchForTheMostRecentSentenceInEmptyList() async throws {
        
        let subtitles = Subtitles(sentences: [])
        let sut = createSUT(subtitles: subtitles)
        
        let result = sut.searchRecentSentence(at: 10)
        XCTAssertNil(result)
    }
    
//    func testSearchForTheMostRecentWordInEmptyList() async throws {
//
//        let subtitles = Subtitles(sentences: [])
//        let sut = createSUT(subtitles: subtitles)
//
//        let sentenceIndex = 10
//
//        let result = sut.searchRecentWord(at: 10, in: sentenceIndex)
//        XCTAssertNil(result)
//    }
    
    func testSearchForTheMostRecentSentenceNotEmptyList() async throws {
        
        let subtitles = getTestSubtitles()
        let sut = createSUT(subtitles: subtitles)
        
        let timeMarks = [0.0, 0.5, 1.0, 1.5, 2.0, 2.5, 3.0, 3.5, 4.0]
        
        let indexSequence = expectSequence([0, 0, 1, 1, 2, 2, 3, 3, 3] as [Int?])
        let sentenceSequence = expectSequence([false, false, false, false, false, false, false, false, false])
        
        for timeMark in timeMarks {
            
            let result = sut.searchRecentSentence(at: timeMark)
            
            indexSequence.fulfill(with: result?.index)
            sentenceSequence.fulfill(with: result?.sentence == nil)
        }
        
        indexSequence.wait(timeout: 3, enforceOrder: true)
        sentenceSequence.wait(timeout: 3, enforceOrder: true)
    }
}
