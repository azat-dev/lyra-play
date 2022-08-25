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
        
        let subtitlesIterator = SubtitlesIteratorImpl(
            subtitlesTimeSlots: timeSlotsParser.parse(from: subtitles)
        )
        let timer = ActionTimerMock2()
        
        let scheduler = SchedulerImpl(timer: timer)
        
        let useCase = PlaySubtitlesUseCaseImpl(
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
    
    private func observeStates(
        _ sut: SUT,
        timeout: TimeInterval = 1,
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws -> (([PlaySubtitlesUseCaseState]) async -> Void) {
        
        var result = [PlaySubtitlesUseCaseState]()
        let observer = sut.useCase.state
            .sink { state in
                result.append(state)
            }
        
        return { expectedStates in
            
            observer.cancel()
            let sequence = self.expectSequence(expectedStates)
            
            result.forEach { sequence.fulfill(with: $0) }
            
            let sequenceObserver = sut.useCase.state.dropFirst().sink { state in
                sequence.fulfill(with: state)
            }
            
            sequence.wait(timeout: timeout, enforceOrder: true, file: file, line: line)
            sequenceObserver.cancel()
        }
    }
    
    private func observeChanges(
        _ sut: SUT,
        timeout: TimeInterval = 1,
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws -> (([WillChangeSubtitlesPositionData]) async -> Void) {
        
        var result = [WillChangeSubtitlesPositionData]()
        let observer = sut.useCase.willChangePosition
            .sink { state in
                result.append(state)
            }
        
        return { expectedStates in
            
            observer.cancel()
            let sequence = self.expectSequence(expectedStates)
            
            result.forEach { sequence.fulfill(with: $0) }
            
            let sequenceObserver = sut.useCase.willChangePosition.dropFirst().sink { state in
                sequence.fulfill(with: state)
            }
            
            sequence.wait(timeout: timeout, enforceOrder: true, file: file, line: line)
            sequenceObserver.cancel()
        }
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
        
        sut.useCase.play()
        
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
        
        let assertStatesEqualTo = try observeStates(sut)
        let assertChangesEqualTo = try observeChanges(sut)
        
        // When
        sut.useCase.play()
        
        // Then
        await assertStatesEqualTo([
            .initial,
            .finished
        ])
        
        await assertChangesEqualTo([])
    }
    
    func test_play__empty_subtitles__with_offset() async throws {
        
        // Given
        let sut = createSUT(subtitles: emptySubtitles())
        
        let assertStatesEqualTo = try observeStates(sut)
        let assertChangesEqualTo = try observeChanges(sut)
        
        // When
        sut.useCase.play(atTime: 100)
        
        // Then
        await assertStatesEqualTo([
            .initial,
            .finished
        ])
        
        await assertChangesEqualTo([])
    }
    
    func test_play__not_empty_subtitles__from_zero() async throws {
        
        // Given
        let sut = createSUT(subtitles: anySubtitles())
        
        let assertStatesEqualTo = try observeStates(sut)
        let assertChangesEqualTo = try observeChanges(sut)
        
        // When
        sut.useCase.play(atTime: 0)
        
        // Then
        await assertStatesEqualTo([
            .initial,
            .playing(position: .sentence(0)),
            .playing(position: .sentence(1)),
            .finished
        ])
        
        await assertChangesEqualTo([
            .init(from: nil, to: .sentence(0)),
            .init(from: .sentence(0), to: .sentence(1)),
            .init(from: .sentence(1), to: nil)
        ])
    }
    
    func test_play__not_empty_subtitles__from_beginning() async throws {
        
        // Given
        let sut = createSUT(subtitles: anySubtitles())
        
        let assertStatesEqualTo = try observeStates(sut)
        let assertChangesEqualTo = try observeChanges(sut)
        
        // When
        sut.useCase.play()
        
        // Then
        await assertStatesEqualTo([
            .initial,
            .playing(position: .sentence(0)),
            .playing(position: .sentence(1)),
            .finished
        ])
        
        await assertChangesEqualTo([
            .init(from: nil, to: .sentence(0)),
            .init(from: .sentence(0), to: .sentence(1)),
            .init(from: .sentence(1), to: nil)
        ])
    }
    
    func test_play__not_empty_subtitles__with_offset() async throws {
        
        // Given
        let sut = createSUT(subtitles: anySubtitles())
        
        let assertStatesEqualTo = try observeStates(sut)
        let assertChangesEqualTo = try observeChanges(sut)
        
        // When
        sut.useCase.play(atTime: 0.1)
        
        // Then
        await assertStatesEqualTo([
            .initial,
            .playing(position: .sentence(1)),
            .finished
        ])
        
        await assertChangesEqualTo([
            .init(from: nil, to: .sentence(1)),
            .init(from: .sentence(1), to: nil),
        ])
    }
    
    func test_pause__stopped() async throws {
        
        let sut = createSUT(subtitles: anySubtitles())
        
        // Given
        try await givenStopped(sut)
        
        let assertStatesEqualTo = try observeStates(sut)
        let assertChangesEqualTo = try observeChanges(sut)
        
        // When
        sut.useCase.pause()
        
        // Then
        await assertStatesEqualTo([
            .stopped,
            .paused(position: .sentence(0))
        ])
        await assertChangesEqualTo([])
    }
    
    func test_pause__playing() async throws {
        
        let sut = createSUT(subtitles: anySubtitles())
        
        // Given
        try await givenPlaying(sut)
        
        let assertStatesEqualTo = try observeStates(sut)
        let assertChangesEqualTo = try observeChanges(sut)
        
        // When
        sut.useCase.pause()
        
        // Then
        await assertStatesEqualTo([
            .playing(position: .sentence(0)),
            .paused(position: .sentence(0))
        ])
        await assertChangesEqualTo([])
    }
    
    func test_stop__not_playing() async throws {
        
        let sut = createSUT(subtitles: anySubtitles())
        
        // Given
        
        let assertStatesEqualTo = try observeStates(sut)
        let assertChangesEqualTo = try observeChanges(sut)
        
        // When
        sut.useCase.stop()
        
        // Then
        await assertStatesEqualTo([
            .initial,
            .stopped
        ])
        await assertChangesEqualTo([])
    }
    
    func test_stop__playing() async throws {
        
        let sut = createSUT(subtitles: anySubtitles())
        
        // Given
        try await givenPlaying(sut)
        
        let assertStatesEqualTo = try observeStates(sut)
        let assertChangesEqualTo = try observeChanges(sut)
        
        // When
        sut.useCase.stop()
        
        // Then
        await assertStatesEqualTo([
            .playing(position: .sentence(0)),
            .stopped
        ])
        await assertChangesEqualTo([])
    }
    
    func test_stop__paused() async throws {
        
        let sut = createSUT(subtitles: anySubtitles())
        
        // Given
        try await givenPaused(sut)
        
        let assertStatesEqualTo = try observeStates(sut)
        let assertChangesEqualTo = try observeChanges(sut)
        
        // When
        sut.useCase.stop()
        
        // Then
        await assertStatesEqualTo([
            .paused(position: .sentence(0)),
            .stopped
        ])
        await assertChangesEqualTo([])
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
