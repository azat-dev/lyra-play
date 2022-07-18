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
        scheduler: Scheduler,
        textSplitter: TextSplitterMock
    )
    
    private let specialCharacters = "\"!@#$^&%*()+=-[]\\/{}|:<>?,._"
    
    func createSUT(subtitles: Subtitles) -> SUT {

        let scheduler = SchedulerMock()
        let textSplitter = TextSplitterMock()
        
        
        let viewModel = DefaultSubtitlesPresenterViewModel(
            subtitles: subtitles,
            textSplitter: textSplitter
        )
        detectMemoryLeak(instance: viewModel)
        
        return (
            viewModel,
            scheduler,
            textSplitter
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
        
        let text1 = "Word1"
        let text2 = "Word3 word4"
        
        let range1 = text2.range(of: "Word3")!
        let range2 = text2.range(of: " ")!
        let range3 = text2.range(of: "word4")!
        
        
        let subtitles = Subtitles(sentences: [
            .init(startTime: 0, duration: 0, text: .notSynced(text: text1)),
            .init(startTime: 0.1, duration: 0, text: .notSynced(text: text2))
        ])
        
        let sut = createSUT(subtitles: subtitles)
        sut.textSplitter.words = [
            .init(type: .word, range: range1, text: String(text2[range1])),
            .init(type: .space, range: range2, text: String(text2[range2])),
            .init(type: .word, range: range3, text: String(text2[range3])),
        ]
        
        await sut.viewModel.load()
        
        let sentenceViewModel = sut.viewModel.getSentenceViewModel(at: 1)
        
        let sentenceModel = try XCTUnwrap(sentenceViewModel)

        let sequence = expectSequence([nil, range1, nil, range1, nil, range1, range3])
        
        sequence.observe(sentenceModel.selectedWordRange)
        
        sentenceModel.toggleWord(1, range1)
        sentenceModel.toggleWord(1, range1)
        sentenceModel.toggleWord(1, range1)
        sentenceModel.toggleWord(1, range2)
        sentenceModel.toggleWord(1, range1)
        sentenceModel.toggleWord(1, range3)
        
        sequence.wait(timeout: 3, enforceOrder: true)
        
        sut.viewModel.state.remove(observer: self)
        sentenceModel.selectedWordRange.remove(observer: self)
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


final class TextSplitterMock: TextSplitter {
    
    var words = [TextComponent]()
    
    func split(text: String) -> [TextComponent] {
    
        return words
    }
}

// MARK: - Helper Types

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
