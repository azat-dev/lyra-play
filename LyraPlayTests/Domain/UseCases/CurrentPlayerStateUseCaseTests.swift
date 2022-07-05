//
//  CurrentPlayerStateUseCaseTests.swift
//  LyraPlayTests
//
//  Created by Azat Kaiumov on 03.07.22.
//

import Foundation

import Foundation

import XCTest
import LyraPlay
import CoreMedia

class CurrentPlayerStateUseCaseTests: XCTestCase {
    
    func createSUT() -> (
        currentPlayerStateUseCase: CurrentPlayerStateUseCase,
        audioService: AudioServiceMock,
        showMediaInfoUseCase: ShowMediaInfoUseCaseMock
    ){
        
        let showMediaInfoUseCase = ShowMediaInfoUseCaseMock()
        let audioService = AudioServiceMock()
        
        let currentPlayerStateUseCase = DefaultCurrentPlayerStateUseCase(
            audioService: audioService,
            showMediaInfoUseCase: showMediaInfoUseCase
        )
        
        detectMemoryLeak(instance: currentPlayerStateUseCase)
        
        return (currentPlayerStateUseCase, audioService, showMediaInfoUseCase)
    }
    
    private func setupTracks(showMediaInfoUseCase: ShowMediaInfoUseCaseMock) -> [MediaInfo] {
        
        var tracks = [MediaInfo]()
        
        for index in 0..<5 {
         
            let trackId = UUID()
            let testTrackData = MediaInfo(
                id: trackId.uuidString,
                coverImage: Data(),
                title: "Test \(index)",
                duration: 10,
                artist: "Artist \(index)"
            )
            
            showMediaInfoUseCase.tracks[trackId] = testTrackData
            tracks.append(testTrackData)
        }
        
        return tracks
    }
    
    func testPlayTrack() async throws {
        
        let (currentPlayerStateUseCase, audioService, showMediaInfoUseCase) = createSUT()
    
        let tracks = setupTracks(showMediaInfoUseCase: showMediaInfoUseCase)
        let track = tracks.first!
        
        let playerStateSequence = AssertSequence(testCase: self, values: [PlayerState.stopped, PlayerState.playing])
        let currentTimeSequence = AssertSequence(testCase: self, values: [0.0, 1.0])
        
        let trackIdSequence = AssertSequence(testCase: self, values: [nil, track.id])
        
        trackIdSequence.observe(currentPlayerStateUseCase.info, mapper: { $0?.id })
        playerStateSequence.observe(currentPlayerStateUseCase.state)
        
        let resultPlay = await audioService.play(
            fileId: track.id,
            data: Data()
        )
        
        try AssertResultSucceded(resultPlay)

        
        currentTimeSequence.observe(currentPlayerStateUseCase.currentTime) { value in
            
            if value > 0 {
                return 1.0
            } else if value < 0 {
                return -1.0
            }
            
            return value
        }

        playerStateSequence.wait(timeout: 3, enforceOrder: true)
        currentTimeSequence.wait(timeout: 3, enforceOrder: true)
        trackIdSequence.wait(timeout: 3, enforceOrder: true)
    }
    
    func testPauseTrack() async throws {
        
        let (currentPlayerStateUseCase, audioService, showMediaInfoUseCase) = createSUT()

        let tracks = setupTracks(showMediaInfoUseCase: showMediaInfoUseCase)
        let track = tracks.first!

        let playerStateSequence = AssertSequence(testCase: self, values: [PlayerState.stopped, PlayerState.playing, PlayerState.paused])
        let currentTimeSequence = AssertSequence(testCase: self, values: [0.0])
        let trackIdSequence = AssertSequence(testCase: self, values: [nil, track.id])

        playerStateSequence.observe(currentPlayerStateUseCase.state)
        trackIdSequence.observe(currentPlayerStateUseCase.info, mapper: { $0?.id })

        let resultPlay = await audioService.play(
            fileId: track.id,
            data: Data()
        )
        try AssertResultSucceded(resultPlay)

        let resultPause = await audioService.pause()
        try AssertResultSucceded(resultPause)

        currentTimeSequence.observe(currentPlayerStateUseCase.currentTime) { value in

            if value > 0 {
                return 1.0
            } else if value < 0 {
                return -1.0
            }

            return value
        }

        trackIdSequence.wait(timeout: 3, enforceOrder: true)
        playerStateSequence.wait(timeout: 3, enforceOrder: true)
        currentTimeSequence.wait(timeout: 3, enforceOrder: true)
    }
    
    func testStopTrack() async throws {
        
        let (currentPlayerStateUseCase, audioService, showMediaInfoUseCase) = createSUT()

        let tracks = setupTracks(showMediaInfoUseCase: showMediaInfoUseCase)
        let track = tracks.first!

        let playerStateSequence = AssertSequence(testCase: self, values: [PlayerState.stopped, PlayerState.playing, PlayerState.stopped])
        let currentTimeSequence = AssertSequence(testCase: self, values: [0.0])
        let trackIdSequence = AssertSequence(testCase: self, values: [nil, track.id, nil])

        playerStateSequence.observe(currentPlayerStateUseCase.state)
        trackIdSequence.observe(currentPlayerStateUseCase.info, mapper: { $0?.id })

        let resultPlay = await audioService.play(
            fileId: track.id,
            data: Data()
        )
        try AssertResultSucceded(resultPlay)

        let resultPause = await audioService.stop()
        try AssertResultSucceded(resultPause)

        currentTimeSequence.observe(currentPlayerStateUseCase.currentTime) { value in

            if value > 0 {
                return 1.0
            } else if value < 0 {
                return -1.0
            }

            return value
        }

        trackIdSequence.wait(timeout: 3, enforceOrder: true)
        playerStateSequence.wait(timeout: 3, enforceOrder: true)
        currentTimeSequence.wait(timeout: 3, enforceOrder: true)
    }
    
    func testChageTrack() async throws {
        
        let (currentPlayerStateUseCase, audioService, showMediaInfoUseCase) = createSUT()

        let tracks = setupTracks(showMediaInfoUseCase: showMediaInfoUseCase)
        let track1 = tracks.first!
        let track2 = tracks[1]

        let playerStateSequence = AssertSequence(testCase: self, values: [PlayerState.stopped, PlayerState.playing, PlayerState.playing])
        let currentTimeSequence = AssertSequence(testCase: self, values: [0.0])
        let trackIdSequence = AssertSequence(testCase: self, values: [nil, track1.id, track2.id])

        playerStateSequence.observe(currentPlayerStateUseCase.state)
        trackIdSequence.observe(currentPlayerStateUseCase.info, mapper: { $0?.id })

        let resultPlay1 = await audioService.play(
            fileId: track1.id,
            data: Data()
        )
        try AssertResultSucceded(resultPlay1)

        
        let resultPlay2 = await audioService.play(
            fileId: track2.id,
            data: Data()
        )
        try AssertResultSucceded(resultPlay2)

        currentTimeSequence.observe(currentPlayerStateUseCase.currentTime) { value in

            if value > 0 {
                return 1.0
            } else if value < 0 {
                return -1.0
            }

            return value
        }

        trackIdSequence.wait(timeout: 3, enforceOrder: true)
        playerStateSequence.wait(timeout: 3, enforceOrder: true)
        currentTimeSequence.wait(timeout: 3, enforceOrder: true)
    }
}
