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
    
    func testLoadEmpty() async throws {

        let subtitles = Subtitles(sentences: [])
        let sut = createSUT(subtitles: subtitles)

        let stateSequence = expectSequence([false, true])
        let numberOfSentencesSequence = expectSequence([nil, 0])
        let activeSentenceIndexSequence = expectSequence([nil, nil] as [Int?])

        sut.viewModel.state.observe(on: self) { state in
            
            stateSequence.fulfill(with: state != nil)
            numberOfSentencesSequence.fulfill(with: state?.numberOfSentences)
            activeSentenceIndexSequence.fulfill(with: state?.activeSentenceIndex)
        }
        
        await sut.viewModel.load()
        
        stateSequence.wait(timeout: 3, enforceOrder: true)
        numberOfSentencesSequence.wait(timeout: 3, enforceOrder: true)
        activeSentenceIndexSequence.wait(timeout: 3, enforceOrder: true)
    }
    
    func testLoad() async throws {

        let subtitles = Subtitles(sentences: [
            .init(startTime: 0, duration: 0, text: .notSynced(text: ""))
        ])
        let sut = createSUT(subtitles: subtitles)

        let stateSequence = expectSequence([false, true])
        let numberOfSentencesSequence = expectSequence([nil, 1])
        let activeSentenceIndexSequence = expectSequence([nil, nil] as [Int?])
        
        sut.viewModel.state.observe(on: self) { state in
            
            stateSequence.fulfill(with: state != nil)
            numberOfSentencesSequence.fulfill(with: state?.numberOfSentences)
            activeSentenceIndexSequence.fulfill(with: state?.activeSentenceIndex)
        }
        
        await sut.viewModel.load()
        
        stateSequence.wait(timeout: 3, enforceOrder: true)
        numberOfSentencesSequence.wait(timeout: 3, enforceOrder: true)
        activeSentenceIndexSequence.wait(timeout: 3, enforceOrder: true)
    }
    
    func testPlayEmpty() async throws {

        let subtitles = Subtitles(sentences: [])
        let sut = createSUT(subtitles: subtitles)

        let stateSequence = expectSequence([false, true])
        let numberOfSentencesSequence = expectSequence([nil, 0])
        let activeSentenceIndexSequence = expectSequence([nil, nil] as [Int?])
        
        sut.viewModel.state.observe(on: self) { state in
            
            stateSequence.fulfill(with: state != nil)
            numberOfSentencesSequence.fulfill(with: state?.numberOfSentences)
            activeSentenceIndexSequence.fulfill(with: state?.activeSentenceIndex)
        }
        
        await sut.viewModel.load()
        await sut.viewModel.play(at: 0.0)
        
        stateSequence.wait(timeout: 3, enforceOrder: true)
        numberOfSentencesSequence.wait(timeout: 3, enforceOrder: true)
        activeSentenceIndexSequence.wait(timeout: 3, enforceOrder: true)
    }
    
    func testPlaySentences() async throws {

        let subtitles = Subtitles(sentences: [
            .init(startTime: 0, duration: 0, text: .notSynced(text: "")),
            .init(startTime: 0.1, duration: 0, text: .notSynced(text: ""))
        ])
        let sut = createSUT(subtitles: subtitles)

        let stateSequence = expectSequence([false, true, true, true])
        let numberOfSentencesSequence = expectSequence([nil, 2, 2, 2])
        let activeSentenceIndexSequence = expectSequence([nil, nil, 0, 1] as [Int?])
        
        sut.viewModel.state.observe(on: self) { state in
            
            stateSequence.fulfill(with: state != nil)
            numberOfSentencesSequence.fulfill(with: state?.numberOfSentences)
            activeSentenceIndexSequence.fulfill(with: state?.activeSentenceIndex)
        }
        
        await sut.viewModel.load()
        await sut.viewModel.play(at: 0.0)
        
        stateSequence.wait(timeout: 3, enforceOrder: true)
        numberOfSentencesSequence.wait(timeout: 3, enforceOrder: true)
        activeSentenceIndexSequence.wait(timeout: 3, enforceOrder: true)
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
