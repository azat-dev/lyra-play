//
//  CurrentPlayerStateUseCaseTests.swift
//  LyraPlayTests
//
//  Created by Azat Kaiumov on 03.07.22.
//

import Foundation

import XCTest
import LyraPlay
import CoreMedia

class CurrentPlayerStateUseCaseTests: XCTestCase {
    
    typealias SUT = (
        useCase: CurrentPlayerStateUseCase,
        audioPlayer: AudioPlayerMock,
        showMediaInfoUseCase: ShowMediaInfoUseCaseMock
    )
    
    func createSUT(file: StaticString = #filePath, line: UInt = #line) -> SUT {
        
        let showMediaInfoUseCase = ShowMediaInfoUseCaseMock()
        let audioPlayer = AudioPlayerMock()
        
        let useCase = CurrentPlayerStateUseCaseImpl(
            audioPlayer: audioPlayer,
            showMediaInfoUseCase: showMediaInfoUseCase
        )
        
        detectMemoryLeak(instance: useCase, file: file, line: line)
        
        return (
            useCase,
            audioPlayer,
            showMediaInfoUseCase
        )
    }
    
    private func setupTracks(showMediaInfoUseCase: ShowMediaInfoUseCaseMock) -> [MediaInfo] {
        
        var tracks = [MediaInfo]()
        
        for index in 0..<5 {
         
            let trackId = UUID()
            let testTrackData = MediaInfo(
                id: trackId.uuidString,
                coverImage: Data(),
                title: "Test \(index)",
                artist: "Artist \(index)",
                duration: 10
            )
            
            showMediaInfoUseCase.tracks[trackId] = testTrackData
            tracks.append(testTrackData)
        }
        
        return tracks
    }
    
    func test_play__track() async throws {
        
        let sut = createSUT()
    
        let tracks = setupTracks(showMediaInfoUseCase: sut.showMediaInfoUseCase)
        let track = tracks.first!
        
        let playerStateSequence = self.expectSequence([PlayerState.stopped, .playing])
        
        let trackIdSequence = self.expectSequence([nil, track.id])
        
        trackIdSequence.observe(sut.useCase.info, mapper: { $0?.id })
        playerStateSequence.observe(sut.useCase.state)
        
        let _ = sut.audioPlayer.prepare(
            fileId: track.id,
            data: Data()
        )
        
        let resultPlay = sut.audioPlayer.play()
        
        try AssertResultSucceded(resultPlay)
        
        playerStateSequence.wait(timeout: 3, enforceOrder: true)
        trackIdSequence.wait(timeout: 3, enforceOrder: true)
    }
    
    func test_pause__playing_track() async throws {
        
        let sut = createSUT()

        let tracks = setupTracks(showMediaInfoUseCase: sut.showMediaInfoUseCase)
        let track = tracks.first!

        let playerStateSequence = self.expectSequence([PlayerState.stopped, PlayerState.playing, PlayerState.paused])
        let trackIdSequence = self.expectSequence([nil, track.id])

        playerStateSequence.observe(sut.useCase.state)
        trackIdSequence.observe(sut.useCase.info, mapper: { $0?.id })

        let _ = sut.audioPlayer.prepare(
            fileId: track.id,
            data: Data()
        )
        let resultPlay = sut.audioPlayer.play()
        try AssertResultSucceded(resultPlay)

        let resultPause = sut.audioPlayer.pause()
        try AssertResultSucceded(resultPause)

        trackIdSequence.wait(timeout: 3, enforceOrder: true)
        playerStateSequence.wait(timeout: 3, enforceOrder: true)
    }
    
    func test_stop_track() async throws {
        
        let sut = createSUT()

        let tracks = setupTracks(showMediaInfoUseCase: sut.showMediaInfoUseCase)
        let track = tracks.first!

        let playerStateSequence = self.expectSequence([
            PlayerState.stopped,
            .playing,
            .stopped
        ])
        
        let trackIdSequence = self.expectSequence([nil, track.id, nil])

        let controlledPlayerState = Observable(sut.useCase.state.value)
        
        sut.useCase.state.observe(on: self) { state in
            
            guard state == .playing else {

                controlledPlayerState.value = state
                return
            }
            
            controlledPlayerState.value = state
            
            let resultStop = sut.audioPlayer.stop()
            try! AssertResultSucceded(resultStop)
        }
        
        playerStateSequence.observe(controlledPlayerState)
        trackIdSequence.observe(sut.useCase.info, mapper: {
            $0?.id
        })
        
        sut.useCase.info.observe(on: self) { info in
            dump(info)
        }
        
        let _ = sut.audioPlayer.prepare(
            fileId: track.id,
            data: Data()
        )

        let resultPlay = sut.audioPlayer.play()
        try AssertResultSucceded(resultPlay)

        trackIdSequence.wait(timeout: 3, enforceOrder: true)
        playerStateSequence.wait(timeout: 3, enforceOrder: true)
    }
    
    func test_change_track() async throws {
        
        let sut = createSUT()

        let tracks = setupTracks(showMediaInfoUseCase: sut.showMediaInfoUseCase)
        let track1 = tracks.first!
        let track2 = tracks[1]

        let playerStateSequence = self.expectSequence([
            PlayerState.stopped,
            .playing,
        ])
        
        let trackIdSequence = self.expectSequence([nil, track1.id, track2.id])

        playerStateSequence.observe(sut.useCase.state)
        trackIdSequence.observe(sut.useCase.info, mapper: { $0?.id })

        let _ = sut.audioPlayer.prepare(
            fileId: track1.id,
            data: Data()
        )
        
        let resultPlay1 = sut.audioPlayer.play()
        try AssertResultSucceded(resultPlay1)

        let _ = sut.audioPlayer.prepare(
            fileId: track2.id,
            data: Data()
        )
        
        let resultPlay2 = sut.audioPlayer.play()
        try AssertResultSucceded(resultPlay2)

        trackIdSequence.wait(timeout: 3, enforceOrder: true)
        playerStateSequence.wait(timeout: 3, enforceOrder: true)
    }
}
