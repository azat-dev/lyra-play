////
////  PlaySubtitlesUseCaseTests.swift
////  LyraPlayTests
////
////  Created by Azat Kaiumov on 01.08.2022.
////
//
//import XCTest
//import LyraPlay
//
//class PlaySubtitlesUseCaseTests: XCTestCase {
//    
//    typealias SUT = (
//        useCase: PlaySubtitlesUseCase,
//        subtitlesIterator: SubtitlesIterator,
//        scheduler: SchedulerMock
//    )
//    
//    func createSUT(subtitles: Subtitles) -> SUT {
//        
//        let subtitlesIteratorFactory = DefaultSubtitlesIterator(subtitles: subtitles)
//        let scheduler = SchedulerMock()
//        
//        let useCase = DefaultPlaySubtitlesUseCase()
//        detectMemoryLeak(instance: useCase)
//        
//        return (
//            useCase,
//            subtitlesIteratorFactory,
//            scheduler
//        )
//    }
//    
//    func emptySubtitles() -> Subtitles {
//        return .init(sentences: [])
//    }
//    
//    func anySubtitles() -> Subtitles {
//        
//        return .init(sentences: [
//            .init(
//                startTime: 0,
//                duration: nil,
//                text: "",
//                timeMarks: [],
//                components: []
//            ),
//            .init(
//                startTime: 0.1,
//                duration: nil,
//                text: "",
//                timeMarks: [],
//                components: []
//            ),
//        ])
//    }
//    
//    func defaultState() -> ExpectedCurrentSubtitlesState {
//        return .init(isNil: true, state: .stopped, position: nil)
//    }
//    
//    func anyTime() -> TimeInterval {
//        return .init()
//    }
//    
//    func test_play__empty_subtitles__from_begining() async throws {
//        
//        let sut = createSUT(subtitles: emptySubtitles())
//        
//        let stateSequence = self.expectSequence([ defaultState() ])
//        stateSequence.observe(sut.useCase.state)
//        sut.useCase.play(at: 0)
//
//        stateSequence.wait(timeout: 5, enforceOrder: true)
//    }
//    
//    func test_play__empty_subtitles__with_offset() async throws {
//
//        let sut = createSUT(subtitles: emptySubtitles())
//        
//        let stateSequence = self.expectSequence([ defaultState() ])
//        stateSequence.observe(sut.useCase.state)
//
//        sut.useCase.play(at: 100)
//
//        stateSequence.wait(timeout: 5, enforceOrder: true)
//    }
//    
//    func test_play__not_empty_subtitles__from_beginning() async throws {
//        
//        let sut = createSUT(subtitles: anySubtitles())
//        
//        let expectedStateItems = [
//            defaultState(),
//            .init(isNil: false, state: .playing, position: .init(isNil: false, sentenceIndex: 0)),
//            .init(isNil: false, state: .playing, position: .init(isNil: false, sentenceIndex: 1)),
//            defaultState(),
//        ]
//        
//        let stateSequence = self.expectSequence(expectedStateItems)
//        stateSequence.observe(sut.useCase.state)
//        
//        sut.useCase.play(at: 0)
//        stateSequence.wait(timeout: 5, enforceOrder: true)
//    }
//    
//    func test_play__not_empty_subtitles__with_offset() async throws {
//        
//        let sut = createSUT(subtitles: anySubtitles())
//        
//        let expectedStateItems = [
//            defaultState(),
//            .init(isNil: false, state: .playing, position: .init(isNil: false, sentenceIndex: 1)),
//            defaultState(),
//        ]
//        
//        let stateSequence = self.expectSequence(expectedStateItems)
//        stateSequence.observe(sut.useCase.state)
//        
//        sut.useCase.play(at: 1)
//        stateSequence.wait(timeout: 5, enforceOrder: true)
//    }
//    
//    func test_pause__stopped() async throws {
//        
//        let sut = createSUT(subtitles: anySubtitles())
//        
//        let expectedStateItems = [
//            defaultState(),
//            .init(isNil: false, state: .playing, position: .init(isNil: false, sentenceIndex: 1)),
//            defaultState(),
//        ]
//        
//        let stateSequence = self.expectSequence(expectedStateItems)
//        stateSequence.observe(sut.useCase.state)
//        
//        sut.useCase.play(at: 1)
//        stateSequence.wait(timeout: 5, enforceOrder: true)
//    }
//    
//    func test_pause__playing() async throws {
//        
//        let sut = createSUT(subtitles: anySubtitles())
//        
//        let expectedStateItems = [
//            defaultState(),
//            .init(isNil: false, state: .playing, position: nil),
//            .init(isNil: false, state: .paused, position: nil),
//            defaultState(),
//        ]
//        let stateSequence = self.expectSequence(expectedStateItems)
//        
//        stateSequence.observe(sut.useCase.state, mapper: { .init(from: $0) })
//        sut.useCase.state.observe(on: self) { newState in
//        
//            if newState.state == .playing {
//                sut.useCase.pause()
//            }
//            
//            if newState.state == .paused {
//                sut.useCase.stop()
//            }
//        }
//        
//        sut.useCase.play(at: 0)
//        stateSequence.wait(timeout: 5, enforceOrder: true)
//    }
//
//    func test_stop__not_playing() async throws {
//        
//        let sut = createSUT(subtitles: anySubtitles())
//        
//        let expectedStateItems = [
//            defaultState(),
//        ]
//
//        let stateSequence = self.expectSequence(expectedStateItems)
//        stateSequence.observe(sut.useCase.state, mapper: { .init(from: $0) })
//
//        sut.useCase.stop()
//        stateSequence.wait(timeout: 5, enforceOrder: true)
//    }
//    
//    func test_stop__playing() async throws {
//        
//        let sut = createSUT(subtitles: anySubtitles())
//        
//        let expectedStateItems = [
//            defaultState(),
//            .init(isNil: false, state: .playing, position: nil),
//            defaultState(),
//        ]
//        
//        let stateSequence = self.expectSequence(expectedStateItems)
//        stateSequence.observe(sut.useCase.state, mapper: { .init(from: $0) })
//        
//        sut.useCase.state.observe(on: self) { newState in
//            
//            if newState.state == .playing {
//                sut.useCase.stop()
//            }
//        }
//        
//        sut.useCase.play(at: 0)
//        stateSequence.wait(timeout: 5, enforceOrder: true)
//    }
//    
//    func test_stop__paused() async throws {
//        
//        let sut = createSUT(subtitles: anySubtitles())
//        
//        let expectedStateItems = [
//            defaultState(),
//            .init(isNil: false, state: .playing),
//            .init(isNil: false, state: .paused),
//            defaultState(),
//        ]
//
//        let stateSequence = self.expectSequence(expectedStateItems)
//        stateSequence.observe(sut.useCase.state, mapper: { .init(fromWithNilPosition: $0) })
//
//        sut.useCase.state.observe(on: self) { newState in
//        
//            if newState.state == .playing {
//                sut.useCase.pause()
//            }
//            
//            if newState.state == .paused {
//                sut.useCase.stop()
//            }
//        }
//        
//        sut.useCase.play(at: 0)
//        stateSequence.wait(timeout: 5, enforceOrder: true)
//    }
//}
//
//// MARK: - Helpers
//
//struct ExpectedCurrentSubtitlesState: Equatable {
//    
//    var isNil: Bool
//    var state: SubtitlesPlayingState? = nil
//    var position: ExpectedSubtitlesPosition? = nil
//    
//    init(
//        isNil: Bool,
//        state: SubtitlesPlayingState? = nil,
//        position: ExpectedSubtitlesPosition? = nil
//    ) {
//        
//        self.isNil = isNil
//        self.state = state
//        self.position = position
//    }
//    
//    init(from source: CurrentSubtitlesState?) {
//        
//        self.isNil = (source == nil)
//        
//        guard let source = source else {
//            return
//        }
//        
//        self.state = source.state
//        
//        if let position = source.position {
//            self.position = ExpectedSubtitlesPosition(from: position)
//        }
//    }
//    
//    init(fromWithNilPosition source: CurrentSubtitlesState?) {
//        
//        self.init(from: source)
//        position = nil
//    }
//}
//
//struct ExpectedSubtitlesPosition: Equatable {
//    
//    var isNil: Bool
//    var sentenceIndex: Int? = nil
//    var timeMarkIndex: Int? = nil
//    
//    init(
//        isNil: Bool,
//        sentenceIndex: Int? = nil,
//        timeMarkIndex: Int? = nil
//    ) {
//        
//        self.isNil = isNil
//        self.sentenceIndex = sentenceIndex
//        self.timeMarkIndex = timeMarkIndex
//    }
//    
//    init(from source: SubtitlesPosition?) {
//        
//        self.isNil = (source == nil)
//        
//        guard let source = source else {
//            return
//        }
//        
//        self.sentenceIndex = source.sentenceIndex
//        self.timeMarkIndex = source.timeMarkIndex
//    }
//}
//
//public enum SubtitlesPlayingState {
//    
//    case playing
//    case paused
//    case stopped
//}
//
//public struct SubtitlesPosition {
//    
//    public var sentenceIndex: Int
//    public var timeMarkIndex: Int?
//    
//    public init(
//        sentenceIndex: Int,
//        timeMarkIndex: Int?
//    ) {
//        
//        self.sentenceIndex = sentenceIndex
//        self.timeMarkIndex = timeMarkIndex
//    }
//}
//
//public struct CurrentSubtitlesState {
//    
//    public var state: SubtitlesPlayingState
//    public var position: SubtitlesPosition?
//    
//    public init(
//        state: SubtitlesPlayingState,
//        position: SubtitlesPosition?
//    ) {
//        
//        self.state = state
//        self.position = position
//    }
//}
