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
    
    func createSUT(subtitles: Subtitles) -> SUT {
        
        let subtitlesIterator = DefaultSubtitlesIterator(subtitles: subtitles)
        let timer = ActionTimerMock()
        
        let scheduler = DefaultScheduler(
            timeMarksIterator: subtitlesIterator,
            timer: timer
        )
        
        let useCase = DefaultPlaySubtitlesUseCase(
            subtitlesIterator: subtitlesIterator,
            scheduler: scheduler
        )
        detectMemoryLeak(instance: useCase)
        
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
    
    func initialState() -> ExpectedCurrentSubtitlesState {
        return .init(state: .initial, position: nil)
    }
    
    func stoppedState() -> ExpectedCurrentSubtitlesState {
        return .init(state: .stopped, position: nil)
    }
    
    func finishedState() -> ExpectedCurrentSubtitlesState {
        return .init(state: .finished, position: nil)
    }
    
    
    func anyTime() -> TimeInterval {
        return .init()
    }
    
    func test_play__empty_subtitles__from_begining() async throws {
        
        let sut = createSUT(subtitles: emptySubtitles())
        
        let stateSequence = self.expectSequence([ initialState(), finishedState() ])
        stateSequence.observe(sut.useCase.state, mapper: { .init(from: $0) })
        sut.useCase.play(at: 0)

        stateSequence.wait(timeout: 1, enforceOrder: true)
        sut.useCase.state.remove(observer: self)
    }
    
    func test_play__empty_subtitles__with_offset() async throws {

        let sut = createSUT(subtitles: emptySubtitles())
        
        let stateSequence = self.expectSequence([ initialState() ])
        stateSequence.observe(sut.useCase.state, mapper: { .init(from: $0) })

        sut.useCase.play(at: 100)

        stateSequence.wait(timeout: 1, enforceOrder: true)
        sut.useCase.state.remove(observer: self)
    }
    
    func test_play__not_empty_subtitles__from_beginning() async throws {
        
        let sut = createSUT(subtitles: anySubtitles())
        
        let expectedStateItems = [
            initialState(),
            .init(state: .playing, position: .init(sentenceIndex: 0)),
            .init(state: .playing, position: .init(sentenceIndex: 1)),
            finishedState(),
        ]
        
        let stateSequence = self.expectSequence(expectedStateItems)
        stateSequence.observe(sut.useCase.state, mapper: { .init(from: $0) })
        
        sut.useCase.play(at: 0)
        stateSequence.wait(timeout: 1, enforceOrder: true)
        sut.useCase.state.remove(observer: self)
    }
    
    func test_play__not_empty_subtitles__with_offset() async throws {
        
        let sut = createSUT(subtitles: anySubtitles())
        
        let expectedStateItems = [
            initialState(),
            .init(state: .playing, position: .init(sentenceIndex: 1)),
            finishedState(),
        ]
        
        let stateSequence = self.expectSequence(expectedStateItems)
        stateSequence.observe(sut.useCase.state, mapper: { .init(from: $0) })
        
        sut.useCase.play(at: 0.1)
        stateSequence.wait(timeout: 1, enforceOrder: true)
        sut.useCase.state.remove(observer: self)
    }
    
    func test_pause__stopped() async throws {
        
        let sut = createSUT(subtitles: anySubtitles())
        
        let expectedStateItems = [
            initialState(),
            .init(state: .playing, position: .init(sentenceIndex: 1)),
            .init(state: .playing, position: .init(sentenceIndex: 1)),
            stoppedState(),
            .init(state: .paused, position: .init(isNil: true))
        ]
        
        let stateSequence = self.expectSequence(expectedStateItems)
        stateSequence.observe(sut.useCase.state, mapper: { .init(from: $0) })
        
        sut.useCase.state.observe(on: self) { state in
            
            if state.state == .playing {
                sut.useCase.stop()
            }
            
            if state.state == .stopped {
                sut.useCase.pause()
            }
        }
        
        sut.useCase.play(at: 0)
        stateSequence.wait(timeout: 1, enforceOrder: true)
        sut.useCase.state.remove(observer: self)
    }
    
    func test_pause__playing() async throws {
        
        let sut = createSUT(subtitles: anySubtitles())
        
        let expectedStateItems = [
            initialState(),
            .init(
                state: .playing,
                position: .init(sentenceIndex: 0)
            ),
            .init(state: .paused, position: nil),
            stoppedState(),
        ]
        let stateSequence = self.expectSequence(expectedStateItems)
        
        stateSequence.observe(sut.useCase.state, mapper: { .init(from: $0) })
        sut.useCase.state.observe(on: self) { newState in
        
            if newState.state == .playing {
                sut.useCase.pause()
            }
            
            if newState.state == .paused {
                sut.useCase.stop()
            }
        }
        
        sut.useCase.play(at: 0)
        stateSequence.wait(timeout: 1, enforceOrder: true)
        sut.useCase.state.remove(observer: self)
    }

    func test_stop__not_playing() async throws {
        
        let sut = createSUT(subtitles: anySubtitles())
        
        let expectedStateItems = [
            initialState(),
            stoppedState()
        ]

        let stateSequence = self.expectSequence(expectedStateItems)
        stateSequence.observe(sut.useCase.state, mapper: { .init(from: $0) })

        sut.useCase.stop()
        stateSequence.wait(timeout: 1, enforceOrder: true)
        sut.useCase.state.remove(observer: self)
    }
    
    func test_stop__playing() async throws {
        
        let sut = createSUT(subtitles: anySubtitles())
        
        let expectedStateItems = [
            initialState(),
            .init(
                state: .playing,
                position: .init(sentenceIndex: 0)
            ),
            stoppedState(),
        ]
        
        let stateSequence = self.expectSequence(expectedStateItems)
        stateSequence.observe(sut.useCase.state, mapper: { .init(from: $0) })
        
        sut.useCase.state.observe(on: self) { newState in
            
            if newState.state == .playing {
                sut.useCase.stop()
            }
        }
        
        sut.useCase.play(at: 0)
        stateSequence.wait(timeout: 1, enforceOrder: true)
        sut.useCase.state.remove(observer: self)
    }
    
    func test_stop__paused() async throws {
        
        let sut = createSUT(subtitles: anySubtitles())
        
        sut.timer.willFire(filter: nil)
        let expectedStateItems = [
            initialState(),
            .init(
                state: .playing,
                position: .init(sentenceIndex: 0)
            ),
            .init(state: .paused),
            stoppedState(),
        ]

        let stateSequence = self.expectSequence(expectedStateItems)
        stateSequence.observe(sut.useCase.state, mapper: { .init(fromWithNilPosition: $0) })

        sut.useCase.state.observe(on: self) { newState in
        
            if newState.state == .playing {
                sut.useCase.pause()
            }
            
            if newState.state == .paused {
                sut.useCase.stop()
            }
        }
        
        sut.useCase.play(at: 0)
        stateSequence.wait(timeout: 1, enforceOrder: true)
        sut.useCase.state.remove(observer: self)
    }
}

// MARK: - Helpers

struct ExpectedCurrentSubtitlesState: Equatable {
    
    var isNil: Bool
    var state: SubtitlesPlayingState? = nil
    var position: ExpectedSubtitlesPosition? = nil

    init(isNil: Bool) {
        
        self.isNil = isNil
    }

    init(
        state: SubtitlesPlayingState? = nil,
        position: ExpectedSubtitlesPosition? = nil
    ) {
        
        self.isNil = false
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
    
    init(fromWithNilPosition source: CurrentSubtitlesState?) {
        
        self.init(from: source)
        position = nil
    }
}

struct ExpectedSubtitlesPosition: Equatable {
    
    var isNil: Bool
    var sentenceIndex: Int? = nil
    var timeMarkIndex: Int? = nil
    
    init(
        sentenceIndex: Int? = nil,
        timeMarkIndex: Int? = nil
    ) {
        
        self.isNil = false
        self.sentenceIndex = sentenceIndex
        self.timeMarkIndex = timeMarkIndex
    }
    
    init (isNil: Bool) {
        
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
