//
//  ShowCurrentSubtitlesStateUseCaseTests.swift
//  LyraPlayTests
//
//  Created by Azat Kaiumov on 30.07.2022.
//

import XCTest
import LyraPlay

 class ShowCurrentSubtitlesStateUseCaseTests: XCTestCase {

    typealias SUT = ShowCurrentSubtitlesStateUseCase

    func createSUT() -> SUT {

        let useCase = DefaultShowCurrentSubtitlesStateUseCase()
        detectMemoryLeak(instance: useCase)

        return useCase
    }

    func test_updateState() async throws {

        let sut = createSUT()

        let testState = CurrentSubtitlesState(isPlaying: true, position: .init(sentenceIndex: 1, timeMarkIndex: 2))

        let expectedStateItems: [ExpectedCurrentSubtitlesState] = [
            .init(isNil: false, isPlaying: false, position: nil),
            .init(from: testState)
        ]
        let stateSequence = self.expectSequence(expectedStateItems)

        stateSequence.observe(sut.state, mapper: { .init(from: $0) })

        sut.updateState(state: testState)

        stateSequence.wait(timeout: 5, enforceOrder: true)
    }
}

// MARK: - Helpers

struct ExpectedCurrentSubtitlesState: Equatable {

    var isNil: Bool
    var isPlaying: Bool? = nil
    var position: ExpectedSubtitlesPosition? = nil

    init(
        isNil: Bool,
        isPlaying: Bool? = nil,
        position: ExpectedSubtitlesPosition? = nil
    ) {

        self.isNil = isNil
        self.isPlaying = isPlaying
        self.position = position
    }

    init(from source: CurrentSubtitlesState?) {

        self.isNil = (source == nil)

        guard let source = source else {
            return
        }

        self.isPlaying = source.isPlaying

        if let position = source.position {
            self.position = ExpectedSubtitlesPosition(from: position)
        }
    }
}

struct ExpectedSubtitlesPosition: Equatable {

    var isNil: Bool
    var sentenceIndex: Int? = nil
    var timeMarkIndex: Int? = nil

    init(
        isNil: Bool,
        sentenceIndex: Int? = nil,
        timeMarkIndex: Int? = nil
    ) {

        self.isNil = isNil
        self.sentenceIndex = sentenceIndex
        self.timeMarkIndex = timeMarkIndex
    }

    init(from source: SubtitlesPosition?) {

        self.isNil = (source == nil)

        guard let source = source else {
            return
        }

        self.sentenceIndex = source.sentenceIndex
        self.timeMarkIndex = source.timeMarkIndex
    }
}
