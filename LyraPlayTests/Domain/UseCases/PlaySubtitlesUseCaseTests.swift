//
//  PlaySubtitlesUseCaseTests.swift
//  LyraPlayTests
//
//  Created by Azat Kaiumov on 01.08.2022.
//

import XCTest
import LyraPlay

 class PlaySubtitlesUseCaseTests: XCTestCase {

    typealias SUT = (
        useCase: PlaySubtitlesUseCase,
        timeMarksIteratorFactory: TimeMarksIteratorFactoryMock,
        scheduler: SchedulerMock
    )

    func createSUT() -> SUT {

        let timeMarksIteratorFactory = TimeMarksIteratorFactoryMock()
        let scheduler = SchedulerMock()

        let useCase = DefaultPlaySubtitlesUseCase()
        detectMemoryLeak(instance: useCase)

        return (
            useCase
            timeMarksIteratorFactory,
            scheduler
        )
    }

    func anySubtitles() -> Subtitles {
        return .init()
    }

    func anyTime() -> TimeInterval {
        return .init()
    }

    func test_play() async throws {

        let sut = createSUT()

        let testSubtitles = anySubtitles()
        let testTime = anyAt()

        let expectedStateItems: [ExpectedCurrentSubtitlesState] = [
        ]
        let stateSequence = self.expectSequence(expectedStateItems)

        stateSequence.observe(sut.useCase.state, mapper: { .init(from: $0) })

        sut.useCase.play(
            subtitles: testSubtitles,
            at: testTime
        )

        stateSequence.wait(timeout: 5, enforceOrder: true)
    }

    func test_pause() async throws {

        let sut = createSUT()

        let expectedStateItems: [ExpectedCurrentSubtitlesState] = [
        ]
        let stateSequence = self.expectSequence(expectedStateItems)

        stateSequence.observe(sut.useCase.state, mapper: { .init(from: $0) })

        sut.useCase.pause()

        stateSequence.wait(timeout: 5, enforceOrder: true)
    }

    func test_stop() async throws {

        let sut = createSUT()

        let expectedStateItems: [ExpectedCurrentSubtitlesState] = [
        ]
        let stateSequence = self.expectSequence(expectedStateItems)

        stateSequence.observe(sut.useCase.state, mapper: { .init(from: $0) })

        sut.useCase.stop()

        stateSequence.wait(timeout: 5, enforceOrder: true)
    }
}

// MARK: - Helpers

struct ExpectedCurrentSubtitlesState: Equatable {

    var isNil: Bool
    var state: SubtitlesPlayingState? = nil
    var position: ExpectedSubtitlesPosition? = nil

    init(
        isNil: Bool,
        state: SubtitlesPlayingState? = nil,
        position: ExpectedSubtitlesPosition? = nil
    ) {

        self.isNil = isNil
        self.state = state
        self.position = position
    }

    init(from source: CurrentSubtitlesState?) {

        self.isNil = (source == nil)

        guard let source = source else {
            return
        }

        self.state = source.state

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

public enum SubtitlesPlayingState {

    case playing
    case paused
    case stopped
}

public struct SubtitlesPosition {

    public var sentenceIndex: Int
    public var timeMarkIndex: Int?

    public init(
        sentenceIndex: Int,
        timeMarkIndex: Int?
    ) {

        self.sentenceIndex = sentenceIndex
        self.timeMarkIndex = timeMarkIndex
    }
}

public struct CurrentSubtitlesState {

    public var state: SubtitlesPlayingState
    public var position: SubtitlesPosition?

    public init(
        state: SubtitlesPlayingState,
        position: SubtitlesPosition?
    ) {

        self.state = state
        self.position = position
    }
}
