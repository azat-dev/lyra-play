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
    
    
    func testSplitSentences() async throws {
        
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
                    .word(0, "Word1"),
                    .specialCharacter(5, ","),
                    .space(6, " "),
                    .word(7, "word2"),
                    .space(12, " "),
                    .word(13, "word3"),
                    .specialCharacter(18, ".")
                ]
            ),
            SentencePresentation(
                items: [
                    .word(0, "Word1"),
                    .specialCharacter(5, ","),
                    .word(6, "word2"),
                    .specialCharacter(11, ","),
                    .word(12, "word3"),
                    .specialCharacter(17, "."),
                    .word(18, "Word4"),
                    .space(23, " "),
                    .word(24, "Word5-Word6"),
                    .space(35, " "),
                    .specialCharacter(36, "-"),
                    .word(37, "Word7")
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
}
