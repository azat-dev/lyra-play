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
        playMediaUseCase: PlayMediaUseCaseMock,
        playSubtitlesUseCaseFactory: PlaySubtitlesUseCaseFactory,
        loadSubtitlesUseCase: LoadSubtitlesUseCaseMock,
        subtitlesTimer: ActionTimer
    )
    
    func createSUT() -> SUT {
        
        let playMediaUseCase = PlayMediaUseCaseMock()
        
        let subtitlesTimer = ActionTimerMock2()
        
        let playSubtitlesUseCaseFactory = DefaultPlaySubtitlesUseCaseFactory(
            subtitlesIteratorFactory: DefaultSubtitlesIteratorFactory(),
            scheduler: DefaultScheduler(timer: subtitlesTimer)
        )
        
        let loadSubtitlesUseCase = LoadSubtitlesUseCaseMock()
        
        let useCase = DefaultPlayMediaWithSubtitlesUseCase(
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
        
        sut.loadSubtitlesUseCase.willReturn = { _, _ in .failure(.itemNotFound) }
        sut.playMediaUseCase.prepareWillReturn = { _ in .failure(.trackNotFound) }
        
        let sessionParams = anySessionParams()
        
        let expectedStateItems: [PlayMediaWithSubtitlesUseCaseState] = [
            .initial,
            .loading(session: sessionParams),
            .loadFailed(session: sessionParams)
        ]
        
        let stateSequence = self.expectSequence(expectedStateItems)
        
        sut.useCase.state.sink { [weak stateSequence] in
            stateSequence?.fulfill(with: $0)
        }.store(in: &disposables)
        
        let result = await sut.useCase.prepare(params: sessionParams)
        
        let error = try AssertResultFailed(result)
        
        guard case .mediaFileNotFound = error else {
            
            XCTFail("Wrong error type \(error)")
            return
        }
        
        stateSequence.wait(timeout: 1, enforceOrder: true)
    }
    
    func test_prepare__not_existing_subtitles() async throws {
        
        let sut = createSUT()
        
        
        sut.loadSubtitlesUseCase.willReturn = { _, _ in .failure(.itemNotFound) }
        sut.playMediaUseCase.prepareWillReturn = { _ in .success(()) }
        
        let sessionParams = anySessionParams()
        
        let expectedStateItems: [PlayMediaWithSubtitlesUseCaseState] = [
            .initial,
            .loading(session: sessionParams),
            .loaded(session: sessionParams, subtitlesState: nil)
        ]
        
        let stateSequence = self.expectSequence(expectedStateItems)
        let disposable = sut.useCase.state.sink { stateSequence.fulfill(with: $0) }
        
        let result = await sut.useCase.prepare(params: sessionParams)
        try AssertResultSucceded(result)
        
        stateSequence.wait(timeout: 1, enforceOrder: true)
        disposable.cancel()
    }
    
    func test_prepare__has_all_data() async throws {
        
        let sut = createSUT()
        
        let subtitles = anySubtitles()
        
        sut.loadSubtitlesUseCase.willReturn = { _, _ in  .success(subtitles) }
        sut.playMediaUseCase.prepareWillReturn = { _ in .success(()) }
        
        let sessionParams = anySessionParams()
        
        let expectedStateItems: [PlayMediaWithSubtitlesUseCaseState] = [
            .initial,
            .loading(session: sessionParams),
            .loaded(session: sessionParams, subtitlesState: .init(position: nil, subtitles: subtitles))
        ]
        
        let stateSequence = self.expectSequence(expectedStateItems)
        let disposable = sut.useCase.state.sink { stateSequence.fulfill(with: $0) }
        
        let result = await sut.useCase.prepare(params: sessionParams)
        try AssertResultSucceded(result)
        
        stateSequence.wait(timeout: 1, enforceOrder: true)
        disposable.cancel()
    }
    
    func test_play__without_preparation() async throws {
        
        let sut = createSUT()
        
        let expectedStateItems: [PlayMediaWithSubtitlesUseCaseState] = [
            .initial,
        ]
        
        let stateSequence = self.expectSequence(expectedStateItems)
        let disposable = sut.useCase.state.sink { stateSequence.fulfill(with: $0) }
        
        let result = sut.useCase.play()
        let error = try AssertResultFailed(result)
        
        guard case .noActiveMedia = error else {
            XCTFail("Wrong error type \(error)")
            return
        }
        
        stateSequence.wait(timeout: 1, enforceOrder: true)
        disposable.cancel()
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
        
        let stateSequence = self.expectSequence(expectedStateItems)
        let subtitlesChangesSequence = self.expectSequence(expecteSubtitlesChanges)
        
        let subtitlesChangesObserver = subtitlesChangesSequence.observe(sut.useCase.willChangeSubtitlesPosition)
        
        let controlledState = PassthroughSubject<PlayMediaWithSubtitlesUseCaseState, Never>()
        let controlledStateObserver = stateSequence.observe(controlledState, file: file, line: line)
        
        let stateObserver = sut.useCase.state
            .enumerated()
            .sink { index, item in
                
                controlledState.send(item)
                controlFlow?(index, item)
            }
        
        action()
        
        stateSequence.wait(timeout: waitFor, enforceOrder: true, file: file, line: line)
        subtitlesChangesSequence.wait(timeout: waitFor, enforceOrder: true, file: file, line: line)
        
        controlledStateObserver.cancel()
        stateObserver.cancel()
        subtitlesChangesObserver.cancel()
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
                
                .initial,
                .loading(session: sessionParams),
                .loaded(session: sessionParams, subtitlesState: .init(position: nil, subtitles: subtitles)),
                .playing(session: sessionParams, subtitlesState: .init(position: nil, subtitles: subtitles)),
                .playing(session: sessionParams, subtitlesState: .init(position: .sentence(0), subtitles: subtitles)),
                .finished(session: sessionParams),
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
                
                .initial,
                .loading(session: sessionParams),
                .loaded(session: sessionParams, subtitlesState: .init(position: nil, subtitles: subtitles)),
                .playing(session: sessionParams, subtitlesState: .init(position: nil, subtitles: subtitles)),
                .playing(session: sessionParams, subtitlesState: .init(position: .sentence(0), subtitles: subtitles)),
                .finished(session: sessionParams),
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
                
                .initial,
                .loading(session: sessionParams),
                .loaded(session: sessionParams, subtitlesState: .init(position: nil, subtitles: subtitles)),
                .playing(session: sessionParams, subtitlesState: .init(position: nil, subtitles: subtitles)),
                .playing(session: sessionParams, subtitlesState: .init(position: .sentence(0), subtitles: subtitles)),
                .paused(session: sessionParams, subtitlesState: .init(position: .sentence(0), subtitles: subtitles), time: 0),
                .playing(session: sessionParams, subtitlesState: .init(position: .sentence(0), subtitles: subtitles)),
                .playing(session: sessionParams, subtitlesState: .init(position: .sentence(1), subtitles: subtitles)),
                .stopped(session: sessionParams),
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
