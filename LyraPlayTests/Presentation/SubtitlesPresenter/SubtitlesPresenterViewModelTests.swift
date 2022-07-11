//
//  SubtitlesPresenterViewModelTests.swift
//  LyraPlayTests
//
//  Created by Azat Kaiumov on 10.07.22.
//

import Foundation
import XCTest
import LyraPlay

class SubtitlesPresenterViewModelTests: XCTestCase {

    typealias SUT = SubtitlesPresenterViewModel
    private let specialCharacters = "\"!@#$^&%*()+=-[]\\/{}|:<>?,._"
    
    func createSUT(subtitles: Subtitles) -> SUT {
        
        let presenterViewModel = DefaultSubtitlesPresenterViewModel(
            subtitles: subtitles
        )
        detectMemoryLeak(instance: presenterViewModel)
        
        return presenterViewModel
    }
    
    
    func testSplitNotSyncSentences() async throws {
        
        let testSubtitles = Subtitles(sentences: [
            .init(
                startTime: 0.1,
                duration: 0,
                text: .notSynced(text: "Word1, word2 word3.")
            ),
            .init(
                startTime: 0.2,
                duration: 0,
                text: .notSynced(text: "Word1,word2,word3.Word4 Word5-Word6 -Word7")
            )
        ])
        
        let sut = createSUT(subtitles: testSubtitles)
        
        let expectedItems: [SentencePresentation] = [
            SentencePresentation(
                items: [
                    
                    .word(position: .init(itemIndex: 0, startsAt: 0), text: "Word1"),
                    .specialCharacter(position: .init(itemIndex: 0, startsAt: 5), text: ","),
                    .space(position: .init(itemIndex: 0, startsAt: 6), text: " "),
                    .word(position: .init(itemIndex: 0, startsAt: 7), text: "word2"),
                    .space(position: .init(itemIndex: 0, startsAt: 12), text: " "),
                    .word(position: .init(itemIndex: 0, startsAt: 13), text: "word3"),
                    .specialCharacter(position: .init(itemIndex: 0, startsAt: 18), text: ".")
                ]
            ),
            SentencePresentation(
                items: [
                    .word(position: .init(itemIndex: 0, startsAt: 0), text: "Word1"),
                    .specialCharacter(position: .init(itemIndex: 0, startsAt: 5), text: ","),
                    .word(position: .init(itemIndex: 0, startsAt: 6), text: "word2"),
                    .specialCharacter(position: .init(itemIndex: 0, startsAt: 11), text: ","),
                    .word(position: .init(itemIndex: 0, startsAt: 12), text: "word3"),
                    .specialCharacter(position: .init(itemIndex: 0, startsAt: 17), text: "."),
                    .word(position: .init(itemIndex: 0, startsAt: 18), text: "Word4"),
                    .space(position: .init(itemIndex: 0, startsAt: 23), text: " "),
                    .word(position: .init(itemIndex: 0, startsAt: 24), text: "Word5-Word6"),
                    .space(position: .init(itemIndex: 0, startsAt: 35), text: " "),
                    .specialCharacter(position: .init(itemIndex: 0, startsAt: 36), text: "-"),
                    .word(position: .init(itemIndex: 0, startsAt: 37), text: "Word7")
                ]
            )
        ]
        
        let itemsSequence = expectSequence(expectedItems.flatMap({ $0.items }))
        
        sut.sentences.observe(on: self) { sentences in
            guard let sentences = sentences else {
                return
            }
            
            sentences.forEach { sentence in
                sentence.items.forEach { item in
                    
                    itemsSequence.fulfill(with: item)
                }
            }
        }
        
        await sut.load()

        itemsSequence.wait(timeout: 3, enforceOrder: true)
    }
    
    func testPlayEmpty() async throws {

        let subtitles = Subtitles(sentences: [])
        let sut = createSUT(subtitles: subtitles)
        
        await sut.load()
        
        let sentenceSequence = expectSequence([nil])
        sentenceSequence.observe(sut.currentSentenceIndex)
        
        let wordSequence = expectSequence([nil])
        wordSequence.observe(sut.currentWordIndex)
        
        await sut.play(at: 10.0, speed: 1.0)
        
        sentenceSequence.wait(timeout: 10, enforceOrder: true)
    }
    
    func testPlayFromBegining() async throws {

        let subtitles = Subtitles(sentences: [
            
            Subtitles.Sentence(
                startTime: 1,
                duration: 0,
                text: .notSynced(text: "")
            ),
            Subtitles.Sentence(
                startTime: 2,
                duration: 0,
                text: .notSynced(text: "")
            ),
            Subtitles.Sentence(
                startTime: 3,
                duration: 0,
                text: .synced(items: [
                    
                    Subtitles.SyncedItem(
                        startTime: 3.1,
                        duration: 0,
                        text: ""
                    ),
                    Subtitles.SyncedItem(
                        startTime: 3.2,
                        duration: 0,
                        text: ""
                    )
                ])
            )
        ])
        
        let sut = createSUT(subtitles: subtitles)
        
        await sut.load()
        
        let sentenceSequence = expectSequence([nil, 0, 1, 2])
        let sentenceTimeSequence = expectSequence([0, 1, 2])
        let expectedSentenceTimes = subtitles.sentences.map { $0.startTime }
        
        sut.currentSentenceIndex.observe(on: self) { index in
            
            sentenceSequence.fulfill(with: index)
            
            guard let index = index else {
                return
            }

            let accuracy = 0.1
            let timeOffset = 0.0
            let expectedTimeOffset = expectedSentenceTimes[index]
            XCTAssertEqual(timeOffset, expectedTimeOffset, accuracy: accuracy)
        }
        
        
        let wordSequence = expectSequence([nil, nil, nil, 0, 1])
        let expectedWordTimes = [3.1, 3.2]
        
        sut.currentWordIndex.observe(on: self) { index in
            
            wordSequence.fulfill(with: index)
            
            guard let index = index else {
                return
            }

            let accuracy = 0.1
            let timeOffset = 0.0
            let expectedTimeOffset = expectedWordTimes[index]
            
            XCTAssertEqual(timeOffset, expectedTimeOffset, accuracy: accuracy)
        }
        
        await sut.play(at: 0.0, speed: 1.0)
        
        sentenceSequence.wait(timeout: 10, enforceOrder: true)
    }
}
