//
//  PlayMediaWithSubtitlesUseCaseTests.swift
//  LyraPlayTests
//
//  Created by Azat Kaiumov on 12.08.2022.
//

import XCTest
import LyraPlay
import Combine

class PlayMediaWithSubtitlesUseCaseTests: XCTestCase {
    
    private var disposables = Set<AnyCancellable>()
    
    typealias SUT = (
        useCase: PlayMediaWithSubtitlesUseCase,
        playMediaUseCase: PlayMediaUseCaseMockStateble,
        playSubtitlesUseCaseFactory: PlaySubtitlesUseCaseFactory,
        loadSubtitlesUseCase: LoadSubtitlesUseCaseMock,
        subtitlesTimer: ActionTimer
    )
    
    func createSUT() -> SUT {
        
        let playMediaUseCase = PlayMediaUseCaseMockStateble()
        
        let subtitlesTimer = ActionTimerMockDeprecated()
        
        let playSubtitlesUseCaseFactory = PlaySubtitlesUseCaseImplFactory(
            subtitlesIteratorFactory: SubtitlesIteratorFactoryImpl(),
            schedulerFactory: SchedulerImplFactory(actionTimerFactory: ActionTimerFactoryMock())
        )
        
        let loadSubtitlesUseCase = LoadSubtitlesUseCaseMock()
        
        let useCase = PlayMediaWithSubtitlesUseCaseImpl(
            playMediaUseCase: playMediaUseCase,
            playSubtitlesUseCaseFactory: playSubtitlesUseCaseFactory,
            loadSubtitlesUseCase: loadSubtitlesUseCase
        )
        detectMemoryLeak(instance: useCase)
        
        return (
            useCase,
            playMediaUseCase,
            playSubtitlesUseCaseFactory,
            loadSubtitlesUseCase,
            subtitlesTimer
        )
    }
    
    private func anySessionParams() -> PlayMediaWithSubtitlesSessionParams {
        return .init(
            mediaId: UUID(),
            subtitlesLanguage: ""
        )
    }
    
    private func anySubtitles() -> Subtitles {
        return .init(duration: 0, sentences: [])
    }
    
    
    func test_prepare__not_existing_media() async throws {
        
        let sut = createSUT()
        
        // Given
        
        sut.loadSubtitlesUseCase.willReturn = { _, _ in .failure(.itemNotFound) }
        sut.playMediaUseCase.prepareWillReturn = { _ in .failure(.trackNotFound) }
        
        let sessionParams = anySessionParams()
        
        let statePromise = watch(sut.useCase.state)
        
        // When
        let result = await sut.useCase.prepare(params: sessionParams)
        
        let error = try AssertResultFailed(result)
        
        guard case .mediaFileNotFound = error else {
            
            XCTFail("Wrong error type \(error)")
            return
        }
        
        statePromise.expect([
            .noActiveSession,
            .activeSession(sessionParams, .loading),
            .activeSession(sessionParams, .loadFailed)
        ], timeout: 1)
    }
    
    func test_prepare__not_existing_subtitles() async throws {
        
        let sut = createSUT()
        
        // Given
        
        sut.loadSubtitlesUseCase.willReturn = { _, _ in .failure(.itemNotFound) }
        sut.playMediaUseCase.prepareWillReturn = { _ in .success(()) }
        
        let sessionParams = anySessionParams()

        let statePromise = watch(sut.useCase.state)
        
        // When
        let result = await sut.useCase.prepare(params: sessionParams)
        try AssertResultSucceded(result)
        
        // Then
        statePromise.expect([
            .noActiveSession,
            .activeSession(sessionParams, .loading),
            .activeSession(sessionParams, .loaded(.initial, nil))
        ], timeout: 1)
    }
    
    func test_prepare__has_all_data() async throws {
        
        let sut = createSUT()
        
        // Given
        let subtitles = anySubtitles()
        
        sut.loadSubtitlesUseCase.willReturn = { _, _ in  .success(subtitles) }
        sut.playMediaUseCase.prepareWillReturn = { _ in .success(()) }
        
        let sessionParams = anySessionParams()

        let statePromise = watch(sut.useCase.state)
        
        // When
        let result = await sut.useCase.prepare(params: sessionParams)
        try AssertResultSucceded(result)

        // Then
        statePromise.expect([
            .noActiveSession,
            .activeSession(sessionParams, .loading),
            .activeSession(sessionParams, .loaded(.initial, .init(position: nil, subtitles: subtitles)))
        ])
    }
    
    func test_play__without_preparation() async throws {
        
        let sut = createSUT()
        
        // Given
        let statePromise = watch(sut.useCase.state)
        
        // When
        let result = sut.useCase.play()
        let error = try AssertResultFailed(result)
        
        // Then
        guard case .noActiveMedia = error else {
            XCTFail("Wrong error type \(error)")
            return
        }
        
        statePromise.expect([
            .noActiveSession
        ])
    }
    
    private func testAction(
        sut: SUT,
        session: PlayMediaWithSubtitlesSessionParams,
        subtitles: Subtitles,
        action: () -> Void,
        waitFor: TimeInterval,
        expectedStateItems: [PlayMediaWithSubtitlesUseCaseState],
        expecteSubtitlesChanges: [WillChangeSubtitlesPositionData],
        controlFlow: ((Int, PlayMediaWithSubtitlesUseCaseState) -> Void)? = nil,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        
        let controlledState = PassthroughSubject<PlayMediaWithSubtitlesUseCaseState, Never>()
        
        let statePromise = watch(controlledState)
        let subtitlesChangesPromise = watch(sut.useCase.willChangeSubtitlesPosition)
        
        let stateObserver = sut.useCase.state
            .enumerated()
            .sink { index, item in
                
                controlledState.send(item)
                controlFlow?(index, item)
            }
        
        // When
        action()
        
        // Then
        statePromise.expect(
            expectedStateItems,
            timeout: waitFor,
            file: file,
            line: line
        )
        
        subtitlesChangesPromise.expect(
            expecteSubtitlesChanges,
            timeout: waitFor,
            file: file,
            line: line
        )
        
        stateObserver.cancel()
    }

    func test_play__finish_media_before_subtitles() async throws {
        
        let sut = createSUT()
        
        let subtitles = Subtitles(duration: 4, sentences: [
            .anySentence(at: 0),
            .anySentence(at: 1),
        ])
        
        sut.loadSubtitlesUseCase.willReturn = { _, _ in  .success(subtitles) }
        sut.playMediaUseCase.prepareWillReturn = { _ in .success(()) }
        
        let sessionParams = anySessionParams()

        let finishAtIndex = 4
        
        testAction(
            sut: sut,
            session: sessionParams,
            subtitles: subtitles,
            action: {
                Task {
                    
                    let _ = await sut.useCase.prepare(params: sessionParams)
                    
                    let result = sut.useCase.play()
                    try AssertResultSucceded(result)
                }
            },
            waitFor: 1,
            expectedStateItems: [
                
                .noActiveSession,
                .activeSession(sessionParams, .loading),
                .activeSession(sessionParams, .loaded(.initial, .init(position: nil, subtitles: subtitles))),
                .activeSession(sessionParams, .loaded(.playing, .init(position: nil, subtitles: subtitles))),
                .activeSession(sessionParams, .loaded(.playing, .init(position: .sentence(0), subtitles: subtitles))),
                .activeSession(sessionParams, .loaded(.finished, .init(position: .sentence(0), subtitles: subtitles))),
            ],
            expecteSubtitlesChanges: [
                .init(from: nil, to: .sentence(0)),
                .init(from: .sentence(0), to: nil),
            ],
            controlFlow: { index, _ in
                
                if index == finishAtIndex {
                    sut.playMediaUseCase.finish()
                }
            }
        )
    }
    
    func test_play__finish_subtitles_before_media() async throws {
        
        let sut = createSUT()
        
        let subtitles = Subtitles(duration: 4, sentences: [
            .anySentence(at: 0),
        ])
        
        sut.loadSubtitlesUseCase.willReturn = { _, _ in  .success(subtitles) }
        sut.playMediaUseCase.prepareWillReturn = { _ in .success(()) }
        
        let sessionParams = anySessionParams()

        let finishAtIndex = 4
        
        testAction(
            sut: sut,
            session: sessionParams,
            subtitles: subtitles,
            action: {
                Task {
                    
                    let _ = await sut.useCase.prepare(params: sessionParams)
                    
                    let result = sut.useCase.play()
                    try AssertResultSucceded(result)
                }
            },
            waitFor: 1,
            expectedStateItems: [
                
                .noActiveSession,
                .activeSession(sessionParams, .loading),
                .activeSession(sessionParams, .loaded(.initial, .init(position: nil, subtitles: subtitles))),
                .activeSession(sessionParams, .loaded(.playing, .init(position: nil, subtitles: subtitles))),
                .activeSession(sessionParams, .loaded(.playing, .init(position: .sentence(0), subtitles: subtitles))),
                .activeSession(sessionParams, .loaded(.finished, .init(position: .sentence(0), subtitles: subtitles))),
            ],
            expecteSubtitlesChanges: [
                .init(from: nil, to: .sentence(0)),
                .init(from: .sentence(0), to: nil),
            ],
            controlFlow: { index, _ in
                
                if index == finishAtIndex {
                    sut.playMediaUseCase.finish()
                }
            }
        )
    }
    
    func test__sync_subtitles_state() async throws {
        
        let sut = createSUT()
        
        let subtitles = Subtitles(duration: 4, sentences: [
            .anySentence(at: 0),
            .anySentence(at: 1),
            .anySentence(at: 2),
            .anySentence(at: 3),
        ])
        
        sut.loadSubtitlesUseCase.willReturn = { _, _ in  .success(subtitles) }
        sut.playMediaUseCase.prepareWillReturn = { _ in .success(()) }
        
        let sessionParams = anySessionParams()
        
        
        let pauseIndex = 4
        let playIndex = pauseIndex + 1
        let stopIndex = playIndex + 2
        
        testAction(
            sut: sut,
            session: sessionParams,
            subtitles: subtitles,
            action: {
                Task {
                    
                    let _ = await sut.useCase.prepare(params: sessionParams)
                    
                    let result = sut.useCase.play()
                    try AssertResultSucceded(result)
                }
            },
            waitFor: 1,
            expectedStateItems: [
              
                .noActiveSession,
                .activeSession(sessionParams, .loading),
                .activeSession(sessionParams, .loaded(.initial, .init(position: nil, subtitles: subtitles))),
                .activeSession(sessionParams, .loaded(.playing, .init(position: nil, subtitles: subtitles))),
                .activeSession(sessionParams, .loaded(.playing, .init(position: .sentence(0), subtitles: subtitles))),
                .activeSession(sessionParams, .loaded(.paused(time: 0), .init(position: .sentence(0), subtitles: subtitles))),
                .activeSession(sessionParams, .loaded(.playing, .init(position: .sentence(0), subtitles: subtitles))),
                .activeSession(sessionParams, .loaded(.playing, .init(position: .sentence(1), subtitles: subtitles))),
                .noActiveSession
            ],
            expecteSubtitlesChanges: [
                .init(from: nil, to: .sentence(0)),
                .init(from: .sentence(0), to: .sentence(1)),
            ],
            controlFlow: { index, state in

                switch index {

                case pauseIndex:
                    let _ = sut.useCase.pause()

                case playIndex:
                    let _ = sut.useCase.play()

                case stopIndex:
                    let _ = sut.useCase.stop()

                default:
                    break
                }
            }
        )
    }
}

// MARK: - Helpers

extension Publisher {
    
    public func enumerated() -> Publishers.Map<Self, (Int, Output)> {
        
        var index = -1
        
        return self.map { item in
            
            index += 1
            return (index, item)
        }
    }
}
