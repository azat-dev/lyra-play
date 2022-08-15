//
//  PlayMediaUseCaseTests.swift
//  LyraPlayTests
//
//  Created by Azat Kaiumov on 10.08.2022.
//

import XCTest
import LyraPlay

class PlayMediaUseCaseTests: XCTestCase {
    
    typealias SUT = (
        useCase: PlayMediaUseCase,
        audioService: AudioServiceMock,
        loadTrackUseCase: LoadTrackUseCaseMock
    )
    
    func createSUT() -> SUT {
        
        let audioService = AudioServiceMock()
        let loadTrackUseCase = LoadTrackUseCaseMock()
        
        let useCase = DefaultPlayMediaUseCase(
            audioService: audioService,
            loadTrackUseCase: loadTrackUseCase
        )
        detectMemoryLeak(instance: useCase)
        
        return (
            useCase,
            audioService,
            loadTrackUseCase
        )
    }
    
    func test_prepare__not_existing_track() async throws {
        
        let sut = createSUT()
        
        let result = await sut.useCase.prepare(mediaId: UUID())
        let error = try AssertResultFailed(result)
        
        guard case .trackNotFound = error else {
            XCTFail("Wrong error type \(error)")
            return
        }
    }
    
    private func setUpTracks(loadTrackUseCase: LoadTrackUseCaseMock) {
        
        for _ in 0..<5 {
            
            let id = UUID()
            loadTrackUseCase.tracks[id] = id.uuidString.data(using: .utf8)
        }
    }
    
    func test_prepare__existing_track() async throws {
        
        let sut = createSUT()
        
        setUpTracks(loadTrackUseCase: sut.loadTrackUseCase)
        
        let track = sut.loadTrackUseCase.tracks.first!
        let trackId = track.0
        
        let expectedStateItems: [PlayMediaUseCaseState] = [
            .initial,
            .loading(mediaId: trackId),
            .loaded(mediaId: trackId),
        ]
        
        let stateSequence = self.expectSequence(expectedStateItems)
        let observer = stateSequence.observe(sut.useCase.state)
        
        let result = await sut.useCase.prepare(mediaId: trackId)
        try AssertResultSucceded(result)
        
        stateSequence.wait(timeout: 3, enforceOrder: true)
        observer.cancel()
    }
    
    func test_play__existing_track() async throws {

        let sut = createSUT()
        
        setUpTracks(loadTrackUseCase: sut.loadTrackUseCase)
        
        let track = sut.loadTrackUseCase.tracks.first!
        let trackId = track.0
        
        let audioServiceStateSequence = self.expectSequence([
            
            AudioServiceState.initial,
            .playing(session: .init(fileId: trackId.uuidString)),
        ])
        
        let audioServiceObserver = audioServiceStateSequence.observe(sut.audioService.state)
        
        let expectedStateItems: [PlayMediaUseCaseState] = [
            .initial,
            .loading(mediaId: trackId),
            .loaded(mediaId: trackId),
            .playing(mediaId: trackId),
//            .finished(mediaId: trackId)
        ]
        
        let stateSequence = self.expectSequence(expectedStateItems)
        let stateObserver = stateSequence.observe(sut.useCase.state)
        
        let _ = await sut.useCase.prepare(mediaId: trackId)
        let result = await sut.useCase.play()
        try AssertResultSucceded(result)
        
        audioServiceStateSequence.wait(timeout: 3, enforceOrder: true)
        stateSequence.wait(timeout: 3, enforceOrder: true)
        
        audioServiceObserver.cancel()
        stateObserver.cancel()
    }
    
    func test_pause__not_active_track() async throws {

        let sut = createSUT()
        
        
        let audioServiceStateSequence = self.expectSequence([
            AudioServiceState.initial,
        ])
        
        let audioServiceObserver = audioServiceStateSequence.observe(sut.audioService.state)
        
        let expectedStateItems: [PlayMediaUseCaseState] = [
            .initial,
        ]
        
        let stateSequence = self.expectSequence(expectedStateItems)
        let stateObserver = stateSequence.observe(sut.useCase.state)
        
        let result = await sut.useCase.pause()
        let error = try AssertResultFailed(result)
        
        guard case .noActiveTrack = error else {
            XCTFail("Wrong error type \(result)")
            return
        }
        
        audioServiceStateSequence.wait(timeout: 3, enforceOrder: true)
        stateSequence.wait(timeout: 3, enforceOrder: true)
        
        audioServiceObserver.cancel()
        stateObserver.cancel()
    }
    
    func test_pause__active_track() async throws {
        
        let sut = createSUT()
        
        setUpTracks(loadTrackUseCase: sut.loadTrackUseCase)
        
        let track = sut.loadTrackUseCase.tracks.first!
        let trackId = track.0
        
        let expectedStateItems: [PlayMediaUseCaseState] = [
            .initial,
            .loading(mediaId: trackId),
            .loaded(mediaId: trackId),
            .playing(mediaId: trackId),
            .paused(mediaId: trackId, time: 0)
        ]
        
        let stateSequence = self.expectSequence(expectedStateItems)
        let stateObserver = stateSequence.observe(sut.useCase.state)
        
        let audioServiceStateSequence = self.expectSequence([
            
            AudioServiceState.initial,
            .playing(session: .init(fileId: trackId.uuidString)),
            .paused(session: .init(fileId: trackId.uuidString), time: 0)
        ])
        
        let audioServiceObserver = audioServiceStateSequence.observe(sut.audioService.state)

        let _ = await sut.useCase.prepare(mediaId: trackId)
        let _ = await sut.useCase.play()
        let result = await sut.useCase.pause()
        try AssertResultSucceded(result)

        audioServiceStateSequence.wait(timeout: 3, enforceOrder: true)
        stateSequence.wait(timeout: 3, enforceOrder: true)
        
        audioServiceObserver.cancel()
        stateObserver.cancel()
    }
    
    func test_change_active_track() async throws {
        
        let sut = createSUT()
        
        setUpTracks(loadTrackUseCase: sut.loadTrackUseCase)
        
        let tracks = Array(sut.loadTrackUseCase.tracks.keys)
        let trackId1 = tracks[0]
        let trackId2 = tracks[1]
        
        let expectedStateItems: [PlayMediaUseCaseState] = [
            .initial,
            .loading(mediaId: trackId1),
            .loaded(mediaId: trackId1),
            .playing(mediaId: trackId1),
            .loading(mediaId: trackId2),
            .loaded(mediaId: trackId2),
            .playing(mediaId: trackId2),
        ]
        
        let stateSequence = self.expectSequence(expectedStateItems)
        let stateObserver = stateSequence.observe(sut.useCase.state)
        
        let audioServiceStateSequence = self.expectSequence([
            
            AudioServiceState.initial,
            .playing(session: .init(fileId: trackId1.uuidString)),
            .playing(session: .init(fileId: trackId2.uuidString)),
        ])
        
        let audioServiceObserver = audioServiceStateSequence.observe(sut.audioService.state)
        
        let _ = await sut.useCase.prepare(mediaId: trackId1)
        let _ = await sut.useCase.play()
        
        let _ = await sut.useCase.prepare(mediaId: trackId2)
        let _ = await sut.useCase.play()
        
        audioServiceStateSequence.wait(timeout: 10, enforceOrder: true)
        stateSequence.wait(timeout: 3, enforceOrder: true)
        
        audioServiceObserver.cancel()
        stateObserver.cancel()
    }
}
