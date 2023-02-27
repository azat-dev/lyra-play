//
//  PlaySubtitlesUseCaseTests.swift
//  LyraPlayTests
//
//  Created by Azat Kaiumov on 01.08.2022.
//

import XCTest
import Combine

import LyraPlay
import Mockingbird

class PlaySubtitlesUseCaseTests: XCTestCase {
    
    typealias SUT = (
        useCase: PlaySubtitlesUseCase,
        subtitlesIterator: SubtitlesIteratorMock,
        scheduler: TimelineSchedulerMock,
        delegate: PlaySubtitlesUseCaseDelegateMock
    )
    
    func createSUT(subtitles: Subtitles, file: StaticString = #filePath, line: UInt = #line) -> SUT {
        
        let subtitlesIterator = mock(SubtitlesIterator.self)
        let scheduler = mock(TimelineScheduler.self)
        
        let schedulerFactory = mock(TimelineSchedulerFactory.self)
        
        given(schedulerFactory.make(timeline: any(), delegate: any()))
            .willReturn(scheduler)
        
        let delegate = mock(PlaySubtitlesUseCaseDelegate.self)
        
        let useCase = PlaySubtitlesUseCaseImpl(
            subtitlesIterator: subtitlesIterator,
            schedulerFactory: schedulerFactory,
            delegate: delegate
        )
        detectMemoryLeak(instance: useCase, file: file, line: line)
        
        releaseMocks(
            subtitlesIterator,
            scheduler,
            delegate
        )
        
        return (
            useCase,
            subtitlesIterator,
            scheduler,
            delegate
        )
    }
    
    // MARK: - Helpers
    
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
    
    private func waitForState(_ sut: SUT, where whereState: (PlaySubtitlesUseCaseState) -> Bool) async throws {
        
        for try await state in sut.useCase.state.values {
            if whereState(state) {
                return
            }
        }
        
        XCTFail("Can't achive state")
    }
    
    private func givenPlaying(_ sut: SUT) async throws {
        
        sut.useCase.play(atTime: 0)
        
        try await waitForState(
            sut,
            where: { state in
                if case .playing = state {
                    return true
                }
                
                return false
            }
        )
    }
    
    private func givenStopped(_ sut: SUT) async throws {
        
        try await givenPlaying(sut)
        sut.useCase.stop()
        
        try await waitForState(
            sut,
            where: { state in
                if case .stopped = state {
                    return true
                }
                
                return false
            }
        )
    }
    
    private func givenPaused(_ sut: SUT) async throws {
        
        try await givenPlaying(sut)
        sut.useCase.pause()
        
        try await waitForState(
            sut,
            where: { state in
                if case .paused = state {
                    return true
                }
                
                return false
            }
        )
    }
    
    // MARK: - Test Methods
    
    func test_play__empty_subtitles__from_begining() async throws {
        
        // Given
        let sut = createSUT(subtitles: emptySubtitles())
        
        let statesPromise = watch(sut.useCase.state)

        // When
        sut.useCase.play(atTime: 0)

        // Then
//        verify(sut.scheduler.execute(from: 0))
//            .wasCalled(1)

//        verify(sut.delegate.playSubtitlesUseCaseWillChange(fromPosition: any(), toPosition: any(), stop: any()))
//            .wasNeverCalled()

    }
    
//    func test_play__empty_subtitles__with_offset() async throws {
//
//        // Given
//        let sut = createSUT(subtitles: emptySubtitles())
//
//        let statesPromise = watch(sut.useCase.state)
//        let changesPromise = watch(sut.useCase.willChangePosition)
//
//        // When
//        sut.useCase.play(atTime: 100)
//
//        // Then
//        statesPromise.expect([
//            .initial,
//            .finished
//        ])
//
//        changesPromise.expect([])
//    }
//
//    func test_play__not_empty_subtitles__from_zero() async throws {
//
//        // Given
//        let sut = createSUT(subtitles: anySubtitles())
//
//        let statesPromise = watch(sut.useCase.state)
//        let changesPromise = watch(sut.useCase.willChangePosition)
//
//        // When
//        sut.useCase.play(atTime: 0)
//
//        // Then
//        statesPromise.expect([
//            .initial,
//            .playing(position: .sentence(0)),
//            .playing(position: .sentence(1)),
//            .finished
//        ])
//
//        changesPromise.expect([
//            .init(from: nil, to: .sentence(0)),
//            .init(from: .sentence(0), to: .sentence(1)),
//            .init(from: .sentence(1), to: nil)
//        ])
//    }
//
//    func test_play__not_empty_subtitles__from_beginning() async throws {
//
//        // Given
//        let sut = createSUT(subtitles: anySubtitles())
//
//        let statesPromise = watch(sut.useCase.state)
//        let changesPromise = watch(sut.useCase.willChangePosition)
//
//        // When
//        sut.useCase.play()
//
//        // Then
//        statesPromise.expect([
//            .initial,
//            .playing(position: .sentence(0)),
//            .playing(position: .sentence(1)),
//            .finished
//        ])
//
//        changesPromise.expect([
//            .init(from: nil, to: .sentence(0)),
//            .init(from: .sentence(0), to: .sentence(1)),
//            .init(from: .sentence(1), to: nil)
//        ])
//    }
//
//    func test_play__not_empty_subtitles__with_offset() async throws {
//
//        // Given
//        let sut = createSUT(subtitles: anySubtitles())
//
//        let statesPromise = watch(sut.useCase.state)
//        let changesPromise = watch(sut.useCase.willChangePosition)
//
//        // When
//        sut.useCase.play(atTime: 0.1)
//
//        // Then
//        statesPromise.expect([
//            .initial,
//            .playing(position: .sentence(1)),
//            .finished
//        ])
//
//        changesPromise.expect([
//            .init(from: nil, to: .sentence(1)),
//            .init(from: .sentence(1), to: nil),
//        ])
//    }
//
//    func test_pause__stopped() async throws {
//
//        let sut = createSUT(subtitles: anySubtitles())
//
//        // Given
//        try await givenStopped(sut)
//
//        let statesPromise = watch(sut.useCase.state)
//        let changesPromise = watch(sut.useCase.willChangePosition)
//
//        // When
//        sut.useCase.pause()
//
//        // Then
//        statesPromise.expect([
//            .stopped,
//            .paused(position: .sentence(0))
//        ])
//        changesPromise.expect([])
//    }
//
//    func test_pause__playing() async throws {
//
//        let sut = createSUT(subtitles: anySubtitles())
//
//        // Given
//        try await givenPlaying(sut)
//
//        let statesPromise = watch(sut.useCase.state)
//        let changesPromise = watch(sut.useCase.willChangePosition)
//
//        // When
//        sut.useCase.pause()
//
//        // Then
//        statesPromise.expect([
//            .playing(position: .sentence(0)),
//            .paused(position: .sentence(0))
//        ])
//        changesPromise.expect([])
//    }
//
//    func test_stop__not_playing() async throws {
//
//        let sut = createSUT(subtitles: anySubtitles())
//
//        // Given
//
//        let statesPromise = watch(sut.useCase.state)
//        let changesPromise = watch(sut.useCase.willChangePosition)
//
//        // When
//        sut.useCase.stop()
//
//        // Then
//        statesPromise.expect([
//            .initial,
//            .stopped
//        ])
//        changesPromise.expect([])
//    }
//
//    func test_stop__playing() async throws {
//
//        let sut = createSUT(subtitles: anySubtitles())
//
//        // Given
//        try await givenPlaying(sut)
//
//        let statesPromise = watch(sut.useCase.state)
//        let changesPromise = watch(sut.useCase.willChangePosition)
//
//        // When
//        sut.useCase.stop()
//
//        // Then
//        statesPromise.expect([
//            .playing(position: .sentence(0)),
//            .stopped
//        ])
//        changesPromise.expect([])
//    }
//
//    func test_stop__paused() async throws {
//
//        let sut = createSUT(subtitles: anySubtitles())
//
//        // Given
//        try await givenPaused(sut)
//
//        let statesPromise = watch(sut.useCase.state)
//        let changesPromise = watch(sut.useCase.willChangePosition)
//
//        // When
//        sut.useCase.stop()
//
//        // Then
//        statesPromise.expect([
//            .paused(position: .sentence(0)),
//            .stopped
//        ])
//        changesPromise.expect([])
//    }
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
