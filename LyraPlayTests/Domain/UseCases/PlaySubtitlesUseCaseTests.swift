//
//  PlaySubtitlesUseCaseTests.swift
//  LyraPlayTests
//
//  Created by Azat Kaiumov on 01.08.2022.
//

import XCTest
import Combine

import LyraPlay

class PlaySubtitlesUseCaseTests: XCTestCase {
    
    typealias SUT = (
        useCase: PlaySubtitlesUseCase,
        subtitlesIterator: SubtitlesIterator,
        scheduler: LyraPlay.Scheduler,
        timer: ActionTimer
    )
    
    func createSUT(subtitles: Subtitles, file: StaticString = #filePath, line: UInt = #line) -> SUT {
        
        let timeSlotsParser = SubtitlesTimeSlotsParser()
        
        let subtitlesIterator = DefaultSubtitlesIterator(
            subtitles: subtitles,
            subtitlesTimeSlots: timeSlotsParser.parse(from: subtitles)
        )
        let timer = ActionTimerMock2()
        
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
    
    func testAction(
        sut: SUT,
        expectedChanges: [WillChangeSubtitlesPositionData],
        expectedStateItems: [PlaySubtitlesUseCaseState],
        action: () -> Void,
        waitFor: TimeInterval,
        controlState: ((_ index: Int, _ state: PlaySubtitlesUseCaseState) -> Void)? = nil,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        
        let changesSequence = expectSequence(expectedChanges)
        let changesObserver = changesSequence.observe(sut.useCase.willChangePosition)
        
        let stateSequence = self.expectSequence(expectedStateItems)
        let controlledState = PassthroughSubject<PlaySubtitlesUseCaseState, Never>()
        let controlledStateObserver = stateSequence.observe(controlledState)
        
        let stateObserver = sut.useCase.state
            .enumerated()
            .sink { index, state in
                
                controlledState.send(state)
                controlState?(index, state)
            }
        
        
        action()
        
        stateSequence.wait(timeout: waitFor, enforceOrder: true, file: file, line: line)
        changesSequence.wait(timeout: waitFor, enforceOrder: true, file: file, line: line)
        
        controlledStateObserver.cancel()
        stateObserver.cancel()
        changesObserver.cancel()
    }
    
    func test_play__empty_subtitles__from_begining() async throws {
        
        let sut = createSUT(subtitles: emptySubtitles())
        
        testAction(
            sut: sut,
            expectedChanges: [],
            expectedStateItems: [.initial, .finished],
            action: { sut.useCase.play() },
            waitFor: 1
        )
    }
    
    func test_play__empty_subtitles__with_offset() async throws {
        
        let sut = createSUT(subtitles: emptySubtitles())
        
        testAction(
            sut: sut,
            expectedChanges: [],
            expectedStateItems: [.initial, .finished],
            action: { sut.useCase.play(atTime: 100) },
            waitFor: 1
        )
    }
    
    func test_play__not_empty_subtitles__from_beginning() async throws {
        
        let sut = createSUT(subtitles: anySubtitles())
        
        testAction(
            sut: sut,
            expectedChanges: [
                .init(from: nil, to: .sentence(0)),
                .init(from: .sentence(0), to: .sentence(1)),
                .init(from: .sentence(1), to: nil)
            ],
            expectedStateItems: [
                .initial,
                .playing(position: .sentence(0)),
                .playing(position: .sentence(1)),
                .finished
            ],
            action: { sut.useCase.play(atTime: 0) },
            waitFor: 1
        )
    }
    
    func test_play__not_empty_subtitles__with_offset() async throws {
        
        let sut = createSUT(subtitles: anySubtitles())
        
        testAction(
            sut: sut,
            expectedChanges: [
                .init(from: nil, to: .sentence(1)),
                .init(from: .sentence(1), to: nil),
            ],
            expectedStateItems: [

                .initial,
                .playing(position: .sentence(1)),
                .finished
            ],
            action: { sut.useCase.play(atTime: 0.1) },
            waitFor: 1
        )
    }
    
    func test_pause__stopped() async throws {
        
        let sut = createSUT(subtitles: anySubtitles())
        
        let stopAtIndex = 1
        let pauseAtIndex = stopAtIndex + 1
        
        testAction(
            sut: sut,
            expectedChanges: [
                .init(from: nil, to: .sentence(0)),
            ],
            expectedStateItems: [
                .initial,
                .playing(position: .sentence(0)),
                .stopped,
                .paused(position: .sentence(0))
            ],
            action: { sut.useCase.play(atTime: 0) },
            waitFor: 1,
            controlState: { index, item in
                
                switch index {
                    
                case stopAtIndex:
                    sut.useCase.stop()
                    return
                    
                case pauseAtIndex:
                    sut.useCase.pause()
                    
                default:
                    break
                }
            }
        )
    }
    
    func test_pause__playing() async throws {
        
        let sut = createSUT(subtitles: anySubtitles())
        let pauseAtIndex = 1
        
        testAction(
            sut: sut,
            expectedChanges: [
                .init(from: nil, to: .sentence(0)),
            ],
            expectedStateItems: [
                .initial,
                .playing(position: .sentence(0)),
                .paused(position: .sentence(0))
            ],
            action: { sut.useCase.play(atTime: 0) },
            waitFor: 1,
            controlState: { index, item in
                
                if index == pauseAtIndex {
                    sut.useCase.pause()
                }
            }
        )
    }
    
    func test_stop__not_playing() async throws {
        
        let sut = createSUT(subtitles: anySubtitles())

        testAction(
            sut: sut,
            expectedChanges: [],
            expectedStateItems: [
                .initial,
                .stopped
            ],
            action: { sut.useCase.stop() },
            waitFor: 1
        )
    }
    
    func test_stop__playing() async throws {
        
        let sut = createSUT(subtitles: anySubtitles())
        let stopAtIndex = 1
        
        testAction(
            sut: sut,
            expectedChanges: [
                .init(from: nil, to: .sentence(0)),
            ],
            expectedStateItems: [
                .initial,
                .playing(position: .sentence(0)),
                .stopped
            ],
            action: { sut.useCase.play(atTime: 0) },
            waitFor: 1,
            controlState: { index, item in
                
                if index == stopAtIndex {
                    sut.useCase.stop()
                }
            }
        )
    }
    
    func test_stop__paused() async throws {
        
        let sut = createSUT(subtitles: anySubtitles())
        
        let pauseAtIndex = 1
        let stopAtIndex = pauseAtIndex + 1
        
        testAction(
            sut: sut,
            expectedChanges: [
                .init(from: nil, to: .sentence(0)),
            ],
            expectedStateItems: [
                .initial,
                .playing(position: .sentence(0)),
                .paused(position: .sentence(0)),
                .stopped
            ],
            action: { sut.useCase.play(atTime: 0) },
            waitFor: 1,
            controlState: { index, item in
                
                switch index {
                    
                case pauseAtIndex:
                    sut.useCase.pause()
                    
                case stopAtIndex:
                    sut.useCase.stop()
                    
                default:
                    break
                }
            }
        )
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
