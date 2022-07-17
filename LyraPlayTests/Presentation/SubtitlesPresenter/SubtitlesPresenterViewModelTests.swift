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

    typealias SUT = (
        viewModel: SubtitlesPresenterViewModel,
        scheduler: Scheduler
    )
    
    private let specialCharacters = "\"!@#$^&%*()+=-[]\\/{}|:<>?,._"
    
    func createSUT(subtitles: Subtitles) -> SUT {

        let scheduler = SchedulerMock()
        
        let viewModel = DefaultSubtitlesPresenterViewModel(
            subtitles: subtitles
        )
        detectMemoryLeak(instance: viewModel)
        
        return (
            viewModel,
            scheduler
        )
    }
    
    func testSplitEmptySentences() async {
        
        let testSubtitles = Subtitles(sentences: [])
        
        let sut = createSUT(subtitles: testSubtitles)
        
        let itemsSequence = expectSequence([nil, 0])
        
        sut.viewModel.sentences.observe(on: self) { sentences in
            guard let sentences = sentences else {
                itemsSequence.fulfill(with: nil)
                return
            }
            
            itemsSequence.fulfill(with: sentences.count)
        }
        
        await sut.viewModel.load()

        itemsSequence.wait(timeout: 3, enforceOrder: true)
    }
    
    func testSplitSentences() async throws {
        
        let text1 = "Word1, word2 word3."
        let text2 = "Word1,word2,word3.Word4 Word5-Word6 -Word7"
        
        let testSubtitles = Subtitles(sentences: [
            .init(
                startTime: 0.1,
                duration: 0,
                text: .notSynced(text: text1)
            ),
            .init(
                startTime: 0.2,
                duration: 0,
                text: .notSynced(text: text2)
            )
        ])
        
        let sut = createSUT(subtitles: testSubtitles)
        

        let itemsIdSequence = expectSequence([nil, 0, 1])
        let itemsActiveSequence = expectSequence([nil, false, false])
        
        sut.viewModel.sentences.observe(on: self) { sentences in
            guard let sentences = sentences else {
                return
            }
            
            sentences.forEach { sentence in
                
                itemsIdSequence.fulfill(with: sentence.id)
                itemsActiveSequence.fulfill(with: sentence.isActive)
            }
        }
        
        await sut.viewModel.load()

        itemsIdSequence.wait(timeout: 3, enforceOrder: true)
        itemsActiveSequence.wait(timeout: 3, enforceOrder: true)
    }
    
    func testPlayEmpty() async throws {

        let subtitles = Subtitles(sentences: [])
        let sut = createSUT(subtitles: subtitles)
        
        await sut.viewModel.load()
        
        let expectation = expectation(description: "Don't call")
        expectation.isInverted = true

        sut.viewModel.currentPosition.observe(on: self) { _ in
            expectation.fulfill()
        }
        
        await sut.viewModel.play(at: 10.0)
    }
    
//    func testPlayFromBegining() async throws {
//
//        let subtitles = Subtitles(sentences: [
//            
//            Subtitles.Sentence(
//                startTime: 1,
//                duration: 0,
//                text: .notSynced(text: "")
//            ),
//            Subtitles.Sentence(
//                startTime: 2,
//                duration: 0,
//                text: .notSynced(text: "")
//            ),
//            Subtitles.Sentence(
//                startTime: 3,
//                duration: 0,
//                text: .synced(items: [
//                    
//                    Subtitles.SyncedItem(
//                        startTime: 3.1,
//                        duration: 0,
//                        text: ""
//                    ),
//                    Subtitles.SyncedItem(
//                        startTime: 3.2,
//                        duration: 0,
//                        text: ""
//                    )
//                ])
//            )
//        ])
//        
//        let sut = createSUT(subtitles: subtitles)
//        
//        await sut.load()
//        
//        let sentenceSequence = expectSequence([nil, 0, 1, 2])
//        let sentenceTimeSequence = expectSequence([0, 1, 2])
//        let expectedSentenceTimes = subtitles.sentences.map { $0.startTime }
//        
//        sut.currentSentenceIndex.observe(on: self) { index in
//            
//            sentenceSequence.fulfill(with: index)
//            
//            guard let index = index else {
//                return
//            }
//
//            let accuracy = 0.1
//            let timeOffset = 0.0
//            let expectedTimeOffset = expectedSentenceTimes[index]
//            XCTAssertEqual(timeOffset, expectedTimeOffset, accuracy: accuracy)
//        }
//        
//        
//        let wordSequence = expectSequence([nil, nil, nil, 0, 1])
//        let expectedWordTimes = [3.1, 3.2]
//        
//        sut.currentWordIndex.observe(on: self) { index in
//            
//            wordSequence.fulfill(with: index)
//            
//            guard let index = index else {
//                return
//            }
//
//            let accuracy = 0.1
//            let timeOffset = 0.0
//            let expectedTimeOffset = expectedWordTimes[index]
//            
//            XCTAssertEqual(timeOffset, expectedTimeOffset, accuracy: accuracy)
//        }
//        
//        await sut.play(at: 0.0, speed: 1.0)
//        
//        sentenceSequence.wait(timeout: 10, enforceOrder: true)
//    }
}

// MARK: - Mocks

fileprivate final class SchedulerMock: Scheduler {

    func start(at: TimeInterval, block: @escaping (TimeInterval) -> Void) {
        
    }
    
    func stop() {
    }
    
    func pause() {
    }
}
