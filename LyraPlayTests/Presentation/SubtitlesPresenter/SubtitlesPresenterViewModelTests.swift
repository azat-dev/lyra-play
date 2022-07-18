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
        
        await sut.viewModel.play(at: 0.0)
        stateSequence.wait(timeout: 3, enforceOrder: true)
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
