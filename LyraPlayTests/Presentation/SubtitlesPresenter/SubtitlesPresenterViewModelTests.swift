//
//  SubtitlesPresenterViewModelTests.swift
//  LyraPlayTests
//
//  Created by Azat Kaiumov on 10.07.22.
//

import Foundation
import XCTest
import LyraPlay

struct SubtitlesPresentationStateEquatable: Equatable {
    
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

struct SentenceViewModelEquatable: Equatable {
    
    var isNil: Bool
    var isActive: Bool?
    var text: String?
    
    init(isNil: Bool, isActive: Bool?, text: String?) {
        self.isNil = false
        self.isActive = isActive
        self.text = text
    }

    init(from model: SentenceViewModel?) {
        
        self.isNil = (model == nil)
        self.isActive = model?.isActive.value
        self.text = model?.text
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
    
    func loadAndObserve(
        subtitles: Subtitles,
        expectedStates: [SubtitlesPresentationStateEquatable],
        file: StaticString = #filePath,
        line: UInt = #line
    ) async -> (SUT, AssertSequence<SubtitlesPresentationStateEquatable>)  {

        let sut = createSUT(subtitles: subtitles)

        let stateSequence = expectSequence(expectedStates)

        sut.viewModel.state.observe(on: self) { state in
            stateSequence.fulfill(with: .init(from: state), file: file, line: line)
        }

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

        let sequenceOnylOneActiveSentenceAtTime = expectSequence([[], [0], [1]])
        
        let viewModel = sut.viewModel
        
        sut.viewModel.state.observe(on: self) { state in
            guard
                let state = state
            else {
                return
            }

            let indexes = (0..<state.numberOfSentences).filter { index in

                let model = viewModel.getSentenceViewModel(at: index)
                return model?.isActive.value ?? false
            }
            
            sequenceOnylOneActiveSentenceAtTime.fulfill(with: indexes)
        }
        await sut.viewModel.play(at: 0.0)
        
        stateSequence.wait(timeout: 3, enforceOrder: true)
        sut.viewModel.state.remove(observer: self)
    }
    
    func testTapWord() async throws {
        
        let text2 = "Word3 word4"
        
        let subtitles = Subtitles(sentences: [
            .init(startTime: 0, duration: 0, text: .notSynced(text: "Word1 word2")),
            .init(startTime: 0.1, duration: 0, text: .notSynced(text: text2))
        ])
        
        let (sut, stateSequence) = await loadAndObserve(
            subtitles: subtitles,
            expectedStates: [
                .init(isNil: true),
                .init(isNil: false, numberOfSentences: 2),
            ]
        )
        
        let sentenceViewModel = sut.viewModel.getSentenceViewModel(at: 1)

        let sequence = expectSequence([nil, text2.range(of: "Word3"), nil])
        
        sequence.observe(sentenceViewModel.selectedWordRange)
        sentenceViewModel?.toggleWord(1, text2.rangeOfComposedCharacterSequence(at: text2.startIndex))
        
    }
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
