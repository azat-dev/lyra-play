//
//  PlayerControlUseCaseTests.swift
//  LyraPlayTests
//
//  Created by Azat Kaiumov on 28.06.22.
//

import Foundation

import XCTest
import LyraPlay

class PlayerControlUseCaseTests: XCTestCase {

    typealias SUT = (
        useCase: PlayerControlUseCase,
        audioService: AudioServiceMock,
        loadTrackUseCase: LoadTrackUseCaseMock
    )
    
    func createSUT() -> SUT {
        
        let audioService = AudioServiceMock()
        let loadTrackUseCase = LoadTrackUseCaseMock()
        
        let useCase = DefaulPlayerControlUseCase(
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
    
    func test_play__not_existing_track() async throws {
        
        let sut = createSUT()
        
        let result = await sut.useCase.play(trackId: UUID())
        let error = try AssertResultFailed(result)
        
        guard case .trackNotFound = error else {
            XCTFail("Wrong error type \(error)")
            return
        }
    }
    
    private func setUpTracks(loadTrackUseCase: LoadTrackUseCaseMock) {
        
        for _ in 0..<5 {
            loadTrackUseCase.tracks[UUID()] = Data()
        }
    }
    
    func test_play__existing_track() async throws {

        let sut = createSUT()
        
        setUpTracks(loadTrackUseCase: sut.loadTrackUseCase)
        
        let track = sut.loadTrackUseCase.tracks.first!
        let trackId = track.0
        
        let audioServiceStateSequence = self.expectSequence([
            
            AudioServiceState.initial,
            .playing(data: .init(fileId: trackId.uuidString)),
        ])
        
        audioServiceStateSequence.observe(sut.audioService.state)
        
        let result = await sut.useCase.play(trackId: trackId)
        try AssertResultSucceded(result)
        
        audioServiceStateSequence.wait(timeout: 3, enforceOrder: true)
    }
    
    func test_pause__not_active_track() async throws {

        let sut = createSUT()
        
        let result = await sut.useCase.pause()
        let error = try AssertResultFailed(result)
        
        guard case .noActiveTrack = error else {
            XCTFail("Wrong error type \(result)")
            return
        }
    }
    
    func test_pause__active_track() async throws {
        
        let sut = createSUT()
        
        setUpTracks(loadTrackUseCase: sut.loadTrackUseCase)
        
        let track = sut.loadTrackUseCase.tracks.first!
        let trackId = track.0
        
        let audioServiceStateSequence = self.expectSequence([
            
            AudioServiceState.initial,
            .playing(data: .init(fileId: trackId.uuidString)),
            .paused(data: .init(fileId: trackId.uuidString), time: 0)
        ])
        
        audioServiceStateSequence.observe(sut.audioService.state)

        let _ = await sut.useCase.play(trackId: trackId)
        let result = await sut.useCase.pause()
        try AssertResultSucceded(result)

        audioServiceStateSequence.wait(timeout: 3, enforceOrder: true)
    }
    
    func test_change_active_track() async throws {
        
        let sut = createSUT()
        
        setUpTracks(loadTrackUseCase: sut.loadTrackUseCase)
        
        let tracks = Array(sut.loadTrackUseCase.tracks.keys)
        let trackId1 = tracks[0]
        let trackId2 = tracks[1]
        
        let audioServiceStateSequence = self.expectSequence([
            
            AudioServiceState.initial,
            .playing(data: .init(fileId: trackId1.uuidString)),
            .playing(data: .init(fileId: trackId2.uuidString)),
        ])
        
        audioServiceStateSequence.observe(sut.audioService.state)
        
        let _ = await sut.useCase.play(trackId: trackId1)
        let _ = await sut.useCase.play(trackId: trackId2)
        
        audioServiceStateSequence.wait(timeout: 10, enforceOrder: true)
    }
}
