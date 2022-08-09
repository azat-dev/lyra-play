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
        audioService: AudioServiceMock,
        showMediaInfoUseCase: ShowMediaInfoUseCaseMock
    )
    
    func createSUT(file: StaticString = #filePath, line: UInt = #line) -> SUT {
        
        let showMediaInfoUseCase = ShowMediaInfoUseCaseMock()
        let audioService = AudioServiceMock()
        
        let useCase = DefaultCurrentPlayerStateUseCase(
            audioService: audioService,
            showMediaInfoUseCase: showMediaInfoUseCase
        )
        
        detectMemoryLeak(instance: useCase, file: file, line: line)
        
        return (
            useCase,
            audioService,
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
                duration: 10,
                artist: "Artist \(index)"
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
        
        let resultPlay = await sut.audioService.play(
            fileId: track.id,
            data: Data()
        )
        
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

        let resultPlay = await sut.audioService.play(
            fileId: track.id,
            data: Data()
        )
        try AssertResultSucceded(resultPlay)

        let resultPause = await sut.audioService.pause()
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
            
            Task {
                
                let resultStop = await sut.audioService.stop()
                try! AssertResultSucceded(resultStop)
            }
        }
        
        playerStateSequence.observe(controlledPlayerState)
        trackIdSequence.observe(sut.useCase.info, mapper: {
            $0?.id
        })
        
        sut.useCase.info.observe(on: self) { info in
            dump(info)
        }

        let resultPlay = await sut.audioService.play(
            fileId: track.id,
            data: Data()
        )
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

        let resultPlay1 = await sut.audioService.play(
            fileId: track1.id,
            data: Data()
        )
        try AssertResultSucceded(resultPlay1)

        
        let resultPlay2 = await sut.audioService.play(
            fileId: track2.id,
            data: Data()
        )
        try AssertResultSucceded(resultPlay2)

        trackIdSequence.wait(timeout: 3, enforceOrder: true)
        playerStateSequence.wait(timeout: 3, enforceOrder: true)
    }
}
