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
            .init(startTime: 0, duration: nil, text: "")
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
            .init(startTime: 0, duration: nil, text: ""),
            .init(startTime: 0.1, duration: nil, text: "")
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
    
    private func getTestText() -> (text: String, components: [TextComponent]){
        
        let text = "Good morning!"
        
        return (
            text,
            [
                .init(type: .word, range: text.range(of: "Good")!),
                .init(type: .space, range: text.range(of: " ")!),
                .init(type: .word, range: text.range(of: "morning")!),
                .init(type: .specialCharacter, range: text.range(of: "!")!),
            ]
        )
    }
    
    func testTapWord() async throws {

        let (text, components) = getTestText()
        
        let subtitles = Subtitles(sentences: [
            .init(startTime: 0, duration: nil, text: text),
            .init(startTime: 0.1, duration: nil, text: text)
        ])
        
        let sut = createSUT(subtitles: subtitles)
        sut.textSplitter.words = components
        
        await sut.viewModel.load()
        
        let sentence0 = sut.viewModel.getSentenceViewModel(at: 0)
        let sentenceModel0 = try XCTUnwrap(sentence0)
        
        let sentence1 = sut.viewModel.getSentenceViewModel(at: 1)
        let sentenceModel1 = try XCTUnwrap(sentence1)

        let sequenceSentence0 = expectSequence([
            // Begining
            nil,
            
            // Toggle same word
            components[0].range,
            nil,
            
            // Toggle space after word
            components[0].range,
            nil,
            
            // Toggle different word
            components[0].range,
            components[2].range,

            // Toggle next line, only one active word
            nil,
            
            // Toggle space on different line to reset word
        ])
        
        let sequenceSentence1 = expectSequence([
            nil,
            components[2].range,
            
            // Toggle space on different line to reset word
            nil
        ])
        
        sequenceSentence0.observe(sentenceModel0.selectedWordRange)
        sequenceSentence1.observe(sentenceModel1.selectedWordRange)
        
        // Toggle same word
        sentenceModel0.toggleWord(sentenceModel0.id, components[0].range)
        sentenceModel0.toggleWord(sentenceModel0.id, components[0].range)
        
        // Toggle space after word
        sentenceModel0.toggleWord(sentenceModel0.id, components[0].range)
        sentenceModel0.toggleWord(sentenceModel0.id, components[1].range)
        
        // Toggle only space
        sentenceModel0.toggleWord(sentenceModel0.id, components[1].range)

        // Toggle different word
        sentenceModel0.toggleWord(sentenceModel0.id, components[0].range)
        sentenceModel0.toggleWord(sentenceModel0.id, components[2].range)

        // Toggle next line, only one active word
        sentenceModel1.toggleWord(sentenceModel1.id, components[2].range)
        
        // Toggle space on different line to reset word
        sentenceModel1.toggleWord(sentenceModel0.id, components[1].range)
        
        sequenceSentence0.wait(timeout: 3, enforceOrder: true)
        sequenceSentence1.wait(timeout: 3, enforceOrder: true)
        
        sut.viewModel.state.remove(observer: self)
        sentenceModel0.selectedWordRange.remove(observer: self)
        sentenceModel1.selectedWordRange.remove(observer: self)
    }
    
    func testOnlyOneActiveWord() async throws {
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
