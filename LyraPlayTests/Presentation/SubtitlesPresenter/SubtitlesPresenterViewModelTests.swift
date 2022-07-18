//
//  SubtitlesPresenterViewModelTests.swift
//  LyraPlayTests
//
//  Created by Azat Kaiumov on 10.07.22.
//

import Foundation
import XCTest
import LyraPlay

private struct SubtitlesPresentationStateEquatable: Equatable {
    
    var isNil: Bool
    var numberOfSentences: Int?
    var activeSentenceIndex: Int?

    init(
        isNil: Bool,
        numberOfSentences: Int? = nil,
        activeSentenceIndex: Int? = nil
    ) {
        
        self.isNil = isNil
        self.numberOfSentences = numberOfSentences
        self.activeSentenceIndex = activeSentenceIndex
    }

    init(from state: SubtitlesPresentationState?) {
        
        isNil = (state == nil)
        numberOfSentences = state?.numberOfSentences
        activeSentenceIndex = state?.activeSentenceIndex
    }
}

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
    
    private func loadAndObserve(
        subtitles: Subtitles,
        expectedStates: [SubtitlesPresentationStateEquatable],
        file: StaticString = #filePath,
        line: UInt = #line
    ) async -> (SUT, AssertSequence<SubtitlesPresentationStateEquatable>)  {

        let sut = createSUT(subtitles: subtitles)

        let stateSequence = expectSequence(expectedStates)

        stateSequence.observe(
            sut.viewModel.state,
            mapper: { .init(from: $0) },
            file: file,
            line: line
        )
        await sut.viewModel.load()

        return (sut, stateSequence)
    }

    func testLoadEmpty() async throws {
        
        let subtitles = Subtitles(sentences: [])
        
        let (_, stateSequence) = await loadAndObserve(
            subtitles: subtitles,
            expectedStates: [
                .init(isNil: true),
                .init(isNil: false, numberOfSentences: 0)
            ]
        )

        stateSequence.wait(timeout: 3, enforceOrder: true)
    }
    
    func testLoad() async throws {

        let subtitles = Subtitles(sentences: [
            .init(startTime: 0, duration: 0, text: .notSynced(text: ""))
        ])
        
        let (_, stateSequence) = await loadAndObserve(
            subtitles: subtitles,
            expectedStates: [
                .init(isNil: true),
                .init(isNil: false, numberOfSentences: 0),
                .init(isNil: false, numberOfSentences: 1)
            ]
        )

        stateSequence.wait(timeout: 3, enforceOrder: true)
    }
    
    func testPlayEmpty() async throws {
        
        let subtitles = Subtitles(sentences: [])
        
        let (sut, stateSequence) = await loadAndObserve(
            subtitles: subtitles,
            expectedStates: [
                .init(isNil: true),
                .init(isNil: false, numberOfSentences: 0)
            ]
        )

        await sut.viewModel.play(at: 0.0)
        stateSequence.wait(timeout: 3, enforceOrder: true)
    }
    
    func testPlaySentences() async throws {
        
        let subtitles = Subtitles(sentences: [
            .init(startTime: 0, duration: 0, text: .notSynced(text: "")),
            .init(startTime: 0.1, duration: 0, text: .notSynced(text: ""))
        ])
        
        let (sut, stateSequence) = await loadAndObserve(
            subtitles: subtitles,
            expectedStates: [
                .init(isNil: true),
                .init(isNil: false, numberOfSentences: 2),
                .init(isNil: false, numberOfSentences: 2, activeSentenceIndex: 0),
                .init(isNil: false, numberOfSentences: 2, activeSentenceIndex: 1)
            ]
        )

        await sut.viewModel.play(at: 0.0)
        stateSequence.wait(timeout: 3, enforceOrder: true)
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
