//
//  PlayMediaWithSubtitlesUseCaseTests.swift
//  LyraPlayTests
//
//  Created by Azat Kaiumov on 12.08.2022.
//

import XCTest
import LyraPlay

class PlayMediaWithSubtitlesUseCaseTests: XCTestCase {
    
    typealias SUT = (
        useCase: PlayMediaWithSubtitlesUseCase,
        playMediaUseCase: PlayMediaUseCaseMock,
        playSubtitlesUseCaseFactory: PlaySubtitlesUseCaseFactory,
        loadSubtitlesUseCase: LoadSubtitlesUseCaseMock,
        subtitlesTimer: ActionTimerMock
    )
    
    func createSUT() -> SUT {
        
        let playMediaUseCase = PlayMediaUseCaseMock()
        
        let subtitlesTimer = ActionTimerMock()
        
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
        
        stateSequence.observe(sut.useCase.state)
        let result = await sut.useCase.prepare(params: sessionParams)
        
        let error = try AssertResultFailed(result)
        
        guard case .mediaFileNotFound = error else {
            
            XCTFail("Wrong error type \(error)")
            return
        }
        
        stateSequence.wait(timeout: 5, enforceOrder: true)
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
        stateSequence.observe(sut.useCase.state)
        
        let result = await sut.useCase.prepare(params: sessionParams)
        try AssertResultSucceded(result)
        
        stateSequence.wait(timeout: 5, enforceOrder: true)
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
        stateSequence.observe(sut.useCase.state)
        
        let result = await sut.useCase.prepare(params: sessionParams)
        try AssertResultSucceded(result)
        
        stateSequence.wait(timeout: 5, enforceOrder: true)
    }
    
    func test_play__without_preparation() async throws {
        
        let sut = createSUT()
        
        let expectedStateItems: [PlayMediaWithSubtitlesUseCaseState] = [
            .initial,
        ]
        
        let stateSequence = self.expectSequence(expectedStateItems)
        stateSequence.observe(sut.useCase.state)
        
        let result = await sut.useCase.play()
        let error = try AssertResultFailed(result)
        
        guard case .noActiveMedia = error else {
            XCTFail("Wrong error type \(error)")
            return
        }
        
        stateSequence.wait(timeout: 5, enforceOrder: true)
    }
    
    func test_play__has_all_data() async throws {
        
        let sut = createSUT()
        
        let subtitles = Subtitles(duration: 0, sentences: [
            anySentence(at: 0),
            anySentence(at: 1),
        ])
        
        sut.loadSubtitlesUseCase.willReturn = { _, _ in  .success(subtitles) }
        sut.playMediaUseCase.prepareWillReturn = { _ in .success(()) }
        
        let sessionParams = anySessionParams()
        
        let expectedStateItems: [PlayMediaWithSubtitlesUseCaseState] = [
            .initial,
            .loading(session: sessionParams),
            .loaded(session: sessionParams, subtitlesState: .init(position: nil, subtitles: subtitles)),
            .playing(session: sessionParams, subtitlesState: .init(position: .sentence(0), subtitles: subtitles)),
            .playing(session: sessionParams, subtitlesState: .init(position: .sentence(1), subtitles: subtitles))
        ]
        
        let stateSequence = self.expectSequence(expectedStateItems)
        stateSequence.observe(sut.useCase.state)
        
        let _ = await sut.useCase.prepare(params: sessionParams)
        let result = await sut.useCase.play()
        
        try AssertResultSucceded(result)
        
        stateSequence.wait(timeout: 5, enforceOrder: true)
    }
}
