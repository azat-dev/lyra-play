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
        subtitlesIterator: SubtitlesIterator,
        scheduler: Scheduler,
        timer: ActionTimerMock
    )
    
    func createSUT(subtitles: Subtitles, file: StaticString = #filePath, line: UInt = #line) -> SUT {
        
        let timeSlotsParser = SubtitlesTimeSlotsParser()
        
        let subtitlesIterator = DefaultSubtitlesIterator(
            subtitles: subtitles,
            subtitlesTimeSlots: timeSlotsParser.parse(from: subtitles)
        )
        let timer = ActionTimerMock()
        
        let scheduler = DefaultScheduler(timer: timer)
        
        let useCase = DefaultPlaySubtitlesUseCase(
            subtitlesIterator: subtitlesIterator,
            scheduler: scheduler
        )
        detectMemoryLeak(instance: useCase, file: file, line: line)
        
        return (
            useCase,
            subtitlesIterator,
            scheduler,
            timer
        )
    }
    
    func emptySubtitles() -> Subtitles {
        return .init(duration: 0, sentences: [])
    }
    
    func anySubtitles() -> Subtitles {
        
        return .init(
            duration: 0.2,
            sentences: [
                .init(
                    startTime: 0,
                    duration: nil,
                    text: "",
                    timeMarks: [],
                    components: []
                ),
                .init(
                    startTime: 0.1,
                    duration: nil,
                    text: "",
                    timeMarks: [],
                    components: []
                ),
            ]
        )
    }
    
    func anyTime() -> TimeInterval {
        return .init()
    }
    
    func test_play__empty_subtitles__from_begining() async throws {
        
        let sut = createSUT(subtitles: emptySubtitles())
        
        let stateSequence = self.expectSequence([
            PlaySubtitlesUseCaseState.initial,
            .finished
        ])
        
        stateSequence.observe(sut.useCase.state)
        sut.useCase.play(atTime: 0)

        stateSequence.wait(timeout: 1, enforceOrder: true)
    }
    
    func test_play__empty_subtitles__with_offset() async throws {

        let sut = createSUT(subtitles: emptySubtitles())

        let stateSequence = self.expectSequence([ PlaySubtitlesUseCaseState.initial ])
        stateSequence.observe(sut.useCase.state)

        sut.useCase.play(atTime: 100)

        stateSequence.wait(timeout: 1, enforceOrder: true)
        sut.useCase.state.remove(observer: self)
    }

    func test_play__not_empty_subtitles__from_beginning() async throws {

        let sut = createSUT(subtitles: anySubtitles())

        let expectedStateItems: [PlaySubtitlesUseCaseState] = [
            .initial,
            .playing(position: .sentence(0)),
            .playing(position: .sentence(1)),
            .finished
        ]

        let stateSequence = self.expectSequence(expectedStateItems)
        stateSequence.observe(sut.useCase.state)

        sut.useCase.play(atTime: 0)
        stateSequence.wait(timeout: 1, enforceOrder: true)
        sut.useCase.state.remove(observer: self)
    }

    func test_play__not_empty_subtitles__with_offset() async throws {

        let sut = createSUT(subtitles: anySubtitles())

        let expectedStateItems: [PlaySubtitlesUseCaseState] = [
            .initial,
            .playing(position: .sentence(1)),
            .finished
        ]

        let stateSequence = self.expectSequence(expectedStateItems)
        stateSequence.observe(sut.useCase.state)

        sut.useCase.play(atTime: 0.1)
        stateSequence.wait(timeout: 1, enforceOrder: true)
        sut.useCase.state.remove(observer: self)
    }

    func test_pause__stopped() async throws {

        let sut = createSUT(subtitles: anySubtitles())

        let expectedStateItems: [PlaySubtitlesUseCaseState] = [
            .initial,
            .playing(position: .sentence(0)),
            .stopped,
            .paused(position: .sentence(0))
        ]

        let stateSequence = self.expectSequence(expectedStateItems)

        let controlledState = Observable(sut.useCase.state.value)

        sut.useCase.state.observe(on: self) { state in

            if state == .stopped {
                
                controlledState.value = state
                sut.useCase.pause()
                return
            }

            if case .playing = state {

                controlledState.value = state
                sut.useCase.stop()
                return
            }

            controlledState.value = state
        }

        stateSequence.observe(controlledState)

        sut.useCase.play(atTime: 0)
        stateSequence.wait(timeout: 1, enforceOrder: true)

        sut.useCase.state.remove(observer: self)
        controlledState.remove(observer: self)
    }

    func test_pause__playing() async throws {

        let sut = createSUT(subtitles: anySubtitles())

        let stateSequence = self.expectSequence([

            PlaySubtitlesUseCaseState.initial,
            .playing(position: .sentence(0)),
            .paused(position: .sentence(0))
        ])

        stateSequence.observe(sut.useCase.state)
        sut.useCase.state.observe(on: self) { newState in

            if case .playing = newState {
                sut.useCase.pause()
            }
        }

        sut.useCase.play(atTime: 0)
        stateSequence.wait(timeout: 1, enforceOrder: true)
        sut.useCase.state.remove(observer: self)
    }

    func test_stop__not_playing() async throws {

        let sut = createSUT(subtitles: anySubtitles())

        let expectedStateItems: [PlaySubtitlesUseCaseState] = [
            .initial,
            .stopped
        ]

        let stateSequence = self.expectSequence(expectedStateItems)
        stateSequence.observe(sut.useCase.state)

        sut.useCase.stop()
        stateSequence.wait(timeout: 1, enforceOrder: true)
        sut.useCase.state.remove(observer: self)
    }

    func test_stop__playing() async throws {

        let sut = createSUT(subtitles: anySubtitles())

        let expectedStateItems: [PlaySubtitlesUseCaseState] = [
            .initial,
            .playing(position: .sentence(0)),
            .stopped
        ]

        let stateSequence = self.expectSequence(expectedStateItems)

        let controlledState = Observable(sut.useCase.state.value)

        sut.useCase.state.observe(on: self) { newState in

            if case .playing = newState {
                controlledState.value = newState
                sut.useCase.stop()
                return
            }

            controlledState.value = newState
        }

        stateSequence.observe(controlledState)

        sut.useCase.play(atTime: 0)
        stateSequence.wait(timeout: 2, enforceOrder: true)
        sut.useCase.state.remove(observer: self)
        controlledState.remove(observer: self)
    }

    func test_stop__paused() async throws {

        let sut = createSUT(subtitles: anySubtitles())

        let expectedStateItems: [PlaySubtitlesUseCaseState] = [
            .initial,
            .playing(position: .sentence(0)),
            .paused(position: .sentence(0)),
            .stopped
        ]

        let controlledState = Observable(sut.useCase.state.value)

        sut.useCase.state.observe(on: self) { newState in

            if case .paused = newState {

                controlledState.value = newState
                sut.useCase.stop()
                return
            }

            if case .playing = newState {

                controlledState.value = newState
                sut.useCase.pause()
                return
            }

            controlledState.value = newState
        }

        let stateSequence = self.expectSequence(expectedStateItems)
        stateSequence.observe(controlledState)

        sut.useCase.play(atTime: 0)
        stateSequence.wait(timeout: 1, enforceOrder: true)
        sut.useCase.state.remove(observer: self)
        controlledState.remove(observer: self)
    }
}

// MARK: - Helpers

struct ExpectedSubtitlesPosition: Equatable {

    var isNil: Bool
    var sentenceIndex: Int? = nil
    var timeMarkIndex: Int? = nil

    init(
        sentenceIndex: Int,
        timeMarkIndex: Int? = nil
    ) {

        self.isNil = false
        self.sentenceIndex = sentenceIndex
        self.timeMarkIndex = timeMarkIndex
    }

    static func sentence(_ index: Int) -> Self {
        return .init(sentenceIndex: index)
    }

    static func nilValue() -> Self {
        return .init(isNil: true)
    }

    private init (isNil: Bool) {

        self.isNil = isNil
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
