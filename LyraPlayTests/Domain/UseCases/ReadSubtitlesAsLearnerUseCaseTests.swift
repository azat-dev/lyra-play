//
//  ReadSubtitlesAsLearnerUseCaseTests.swift
//  LyraPlayTests
//
//  Created by Azat Kaiumov on 20.07.22.
//

import Foundation
import XCTest
import LyraPlay

class ReadSubtitlesAsLearnerUseCaseTests: XCTestCase {
    
    typealias SUT = (
        useCase: ReadSubtitlesAsLearnerUseCase
    )
    
    func createSUT(subtitles: Subtitles) -> SUT {
        
        let presenterViewModel = DefaultReadSubtitlesAsLearnerUseCase(
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
    
    //    func testSplitSyncSentences() async throws {
    //
    //        let testSubtitles = Subtitles(sentences: [
    //            .init(startTime: 0.1, duration: 0, text: .synced(items: <#T##[Subtitles.SyncedItem]#>))
    //        ])
    //        let sut = createSUT()
    //    }
}

