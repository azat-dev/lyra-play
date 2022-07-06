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
    
    func testPlayNotExistingTrack() async throws {
        
        let (useCase, _, _) = createSUT()
        
        let result = await useCase.play(trackId: UUID())
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
    
    func testPlayExistingTrack() async throws {

        let (useCase, audioService, loadTrackUseCase) = createSUT()
        
        setUpTracks(loadTrackUseCase: loadTrackUseCase)
        
        let track = loadTrackUseCase.tracks.first!
        let trackId = track.0
        
        let trackIdSequence = AssertSequence(testCase: self, values: [nil, trackId.uuidString])
        let playingSequence = AssertSequence(testCase: self, values: [false, true])
        
        trackIdSequence.observe(audioService.fileId)
        playingSequence.observe(audioService.isPlaying)
        
        let result = await useCase.play(trackId: trackId)
        try AssertResultSucceded(result)
        
        trackIdSequence.wait(timeout: 3, enforceOrder: true)
        playingSequence.wait(timeout: 3, enforceOrder: true)
    }
    
    func testPauseNotActiveTrack() async throws {

        let (useCase, _, _) = createSUT()
        
        let result = await useCase.pause()
        let error = try AssertResultFailed(result)
        
        guard case .noActiveTrack = error else {
            XCTFail("Wrong error type \(result)")
            return
        }
    }
    
    func testPauseActiveTrack() async throws {
        
        let (useCase, audioService, loadTrackUseCase) = createSUT()
        
        setUpTracks(loadTrackUseCase: loadTrackUseCase)
        
        let track = loadTrackUseCase.tracks.first!
        let trackId = track.0
        
        let trackIdSequence = AssertSequence(testCase: self, values: [nil, trackId.uuidString])
        let playingSequence = AssertSequence(testCase: self, values: [false, true, false])
        
        trackIdSequence.observe(audioService.fileId)
        playingSequence.observe(audioService.isPlaying)
        
        let _ = await useCase.play(trackId: trackId)
        let result = await useCase.pause()
        try AssertResultSucceded(result)
        
        trackIdSequence.wait(timeout: 3, enforceOrder: true)
        playingSequence.wait(timeout: 3, enforceOrder: true)
    }
    
    func testChangeActiveTrack() async throws {
        
        let (useCase, audioService, loadTrackUseCase) = createSUT()
        
        setUpTracks(loadTrackUseCase: loadTrackUseCase)
        
        let tracks = Array(loadTrackUseCase.tracks.keys)
        let trackId1 = tracks[0]
        let trackId2 = tracks[1]
        
        let trackIdSequence = AssertSequence(testCase: self, values: [nil, trackId1.uuidString, trackId2.uuidString])
        let playingSequence = AssertSequence(testCase: self, values: [false, true, true])
        
        trackIdSequence.observe(audioService.fileId)
        playingSequence.observe(audioService.isPlaying)
        
        let _ = await useCase.play(trackId: trackId1)
        let _ = await useCase.play(trackId: trackId2)
        
        trackIdSequence.wait(timeout: 3, enforceOrder: true)
        playingSequence.wait(timeout: 3, enforceOrder: true)
    }
}
