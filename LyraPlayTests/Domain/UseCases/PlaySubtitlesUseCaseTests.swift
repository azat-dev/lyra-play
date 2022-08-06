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
            timeLineIterator: subtitlesIterator,
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
        return .init(state: .initial)
    }
    
    func stoppedState() -> ExpectedCurrentSubtitlesState {
        return .init(state: .stopped)
    }
    
    func finishedState() -> ExpectedCurrentSubtitlesState {
        return .init(state: .finished)
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
            .init(state: .playing, position: .sentence(0)),
            .init(state: .playing, position: .sentence(1)),
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
            .init(state: .playing, position: .sentence(1)),
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
            .init(state: .playing, position: .sentence(0)),
            stoppedState(),
            .init(state: .paused)
        ]
        
        let stateSequence = self.expectSequence(expectedStateItems)
        
        let controlledState = Observable(sut.useCase.state.value)
        
        sut.useCase.state.observe(on: self) { state in
            
            if state.state == .stopped {
                
                controlledState.value = state
                sut.useCase.pause()
                return
            }

            if state.state == .playing {
                
                controlledState.value = state
                sut.useCase.stop()
                return
            }
            
            controlledState.value = state
        }
        
        stateSequence.observe(controlledState, mapper: { .init(from: $0) })
        
        sut.useCase.play(at: 0)
        stateSequence.wait(timeout: 1, enforceOrder: true)
        
        sut.useCase.state.remove(observer: self)
        controlledState.remove(observer: self)
    }
    
    func test_pause__playing() async throws {
        
        let sut = createSUT(subtitles: anySubtitles())
        
        let stateSequence = self.expectSequence([
         
            initialState(),
            .init(state: .playing, position: .sentence(0)),
            .init(state: .paused, position: .sentence(0)),
        ])
        
        stateSequence.observe(sut.useCase.state, mapper: { .init(from: $0) })
        sut.useCase.state.observe(on: self) { newState in
        
            if newState.state == .playing {
                sut.useCase.pause()
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
                position: .sentence(0)
            ),
            stoppedState(),
        ]
        
        let stateSequence = self.expectSequence(expectedStateItems)
        
        let controlledState = Observable(sut.useCase.state.value)
        
        sut.useCase.state.observe(on: self) { newState in
            
            if newState.state == .playing {
                controlledState.value = newState
                sut.useCase.stop()
                return
            }
            
            controlledState.value = newState
        }
        
        stateSequence.observe(controlledState, mapper: { .init(from: $0) })
        
        sut.useCase.play(at: 0)
        stateSequence.wait(timeout: 2, enforceOrder: true)
        sut.useCase.state.remove(observer: self)
        controlledState.remove(observer: self)
    }
    
    func test_stop__paused() async throws {
        
        let sut = createSUT(subtitles: anySubtitles())
        
        let expectedStateItems = [
            initialState(),
            .init(state: .playing, position: .sentence(0)),
            .init(state: .paused, position: .sentence(0)),
            stoppedState(),
        ]

        let controlledState = Observable(sut.useCase.state.value)
        
        sut.useCase.state.observe(on: self) { newState in
        
            if newState.state == .paused {
                
                controlledState.value = newState
                sut.useCase.stop()
                return
            }
            
            if newState.state == .playing {
                
                controlledState.value = newState
                sut.useCase.pause()
                return
            }
            
            controlledState.value = newState
        }
        
        let stateSequence = self.expectSequence(expectedStateItems)
        stateSequence.observe(controlledState, mapper: { .init(from: $0) })

        sut.useCase.play(at: 0)
        stateSequence.wait(timeout: 1, enforceOrder: true)
        sut.useCase.state.remove(observer: self)
        controlledState.remove(observer: self)
    }
}

// MARK: - Helpers

struct ExpectedCurrentSubtitlesState: Equatable {
    
    var isNil: Bool
    var state: SubtitlesPlayingState? = nil
    var position: ExpectedSubtitlesPosition = .nilValue()

    init(isNil: Bool) {
        self.isNil = isNil
    }
    
    static func nilValue() -> Self {
        return .init(isNil: true)
    }

    init(
        state: SubtitlesPlayingState,
        position: ExpectedSubtitlesPosition = .nilValue()
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
        } else {
            self.position = .nilValue()
        }
    }
}

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
