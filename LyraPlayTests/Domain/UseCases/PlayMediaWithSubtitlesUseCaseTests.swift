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
        
        let subtitlesTimer = DefaultActionTimer()
        
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
    
    private func anySentence(at: TimeInterval, timeMarks: [Subtitles.TimeMark]? = nil, text: String = "") -> Subtitles.Sentence {
        
        return Subtitles.Sentence(
            startTime: at,
            duration: nil,
            text: text,
            timeMarks: timeMarks,
            components: []
        )
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

        let result = await sut.useCase.play()
        let error = try AssertResultFailed(result)

        guard case .noActiveMedia = error else {
            XCTFail("Wrong error type \(error)")
            return
        }

        stateSequence.wait(timeout: 1, enforceOrder: true)
        disposable.cancel()
    }

    func test__sync_subtitles_state() async throws {

        let sut = createSUT()

        let subtitles = Subtitles(duration: 4, sentences: [
            anySentence(at: 0),
            anySentence(at: 1),
            anySentence(at: 2),
        ])

        sut.loadSubtitlesUseCase.willReturn = { _, _ in  .success(subtitles) }
        sut.playMediaUseCase.prepareWillReturn = { _ in .success(()) }

        let sessionParams = anySessionParams()

        let expectedStateItems: [PlayMediaWithSubtitlesUseCaseState] = [
            .initial,
            .loading(session: sessionParams),
            .loaded(session: sessionParams, subtitlesState: .init(position: nil, subtitles: subtitles)),
            .playing(session: sessionParams, subtitlesState: .init(position: nil, subtitles: subtitles)),
            .playing(session: sessionParams, subtitlesState: .init(position: .sentence(0), subtitles: subtitles)),
            .paused(session: sessionParams, subtitlesState: .init(position: .sentence(0), subtitles: subtitles), time: 0),
            .playing(session: sessionParams, subtitlesState: .init(position: .sentence(0), subtitles: subtitles)),
            .playing(session: sessionParams, subtitlesState: .init(position: .sentence(1), subtitles: subtitles)),
            .stopped(session: sessionParams),
        ]

        let stateSequence = self.expectSequence(expectedStateItems)
        var paused = false
        var played = false

        let disposable = sut.useCase.state
            .filter { state in

                switch state {

                case .playing(_, let subitlesState) where subitlesState?.position == .sentence(0):
                    if paused {
                        break
                    }

                    paused = true
                    Task {
                        let _ = await sut.useCase.pause()
                    }

                case .paused:
                    if played {
                        break
                    }

                    played = true
                    Task { let _ = await sut.useCase.play() }

                case .playing(_, let subitlesState) where subitlesState?.position == .sentence(1):
                    Task { let _ = await sut.useCase.stop() }

                default:
                    break
                }

                return true
            }
            .sink { stateSequence.fulfill(with: $0) }

        let _ = await sut.useCase.prepare(params: sessionParams)

        let result = await sut.useCase.play()
        try AssertResultSucceded(result)

        
        stateSequence.wait(timeout: 5, enforceOrder: true)
        disposable.cancel()
    }
}
