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

class CurrentPlayerStateUseCaseTests: XCTestCase {
    
    private var currentPlayerStateUseCase: CurrentPlayerStateUseCase!
    private var audioService: AudioPlayerService!
    private var showMediaInfoUseCase: ShowMediaInfoUseCaseMock!
    
    override func setUp() {
        
        showMediaInfoUseCase = ShowMediaInfoUseCaseMock()
        
        currentPlayerStateUseCase = DefaultCurrentPlayerStateUseCase(
            showMediaInfoUseCase: showMediaInfoUseCase,
            audioServiceOutput: DefaultAudioPlayerService()
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
            tracks[testTrackData]
        }
        
        return tracks
    }
    
    func testPlayTrack() async throws {
    
        let tracks = setupTracks(showMediaInfoUseCase: showMediaInfoUseCase)
        let track = tracks.first!
        
        let playerStateSequence = AssertSequence(testCase: self, values: [PlayerState.none, PlayerState.playing])
        
        let currentTimeSequence = AssertSequence(testCase: self, values: [0, 1])
        
        let trackIdSequence = AssertSequence(testCase: self, values: [nil, track.id])
        
        let resultPlay = await audioService.play(
            mediaInfo: track,
            data: Data()
        )
        
        try AssertResultSucceded(resultPlay)
        sleep(1)
        
        currentPlayerStateUseCase.info.observe(on: self, observerBlock: trackIdSequence.observe)
        currentPlayerStateUseCase.state.observe(on: self, observeBlock: playerStateSequence.observe)
        currentPlayerStateUseCase.currentTime.observe(on: self) { value in
            
            var mappedValue = value

            if value > 0 {
                mappedValue = 1
            } else if value < 0 {
                mappedValue = -1
            }
            
            currentTimeSequence.observe(mappedValue)
        }
        
        playerStateSequence.wait(timeout: 10, enforceOrder: true)
        currentTimeSequence.wait(timeout: 10, enforceOrder: true)
    }
    
    func testPauseTrack() async throws {
        
        let tracks = setupTracks(showMediaInfoUseCase: showMediaInfoUseCase)
        let track = tracks.first!
        
        let playerStateSequence = AssertSequence(testCase: self, values: [PlayerState.playing, PlayerState.paused])
        
        let currentTimeSequence = AssertSequence(testCase: self, values: [1])
        
        let trackIdSequence = AssertSequence(testCase: self, values: [track.id, track.id])
        
        let resultPlay = await audioService.play(
            mediaInfo: track,
            data: Data()
        )
        try AssertResultSucceded(resultPlay)
        
        sleep(1)
        
        let resultPause = await audioService.pause()
        try AssertResultSucceded(resultPause)
        
        currentPlayerStateUseCase.info.observe(on: self, observerBlock: trackIdSequence.observe)
        currentPlayerStateUseCase.state.observe(on: self, observe: playerStateSequence.observe)
        currentPlayerStateUseCase.currentTime.observe(on: self) { value in
            
            var mappedValue = value

            if value > 0 {
                mappedValue = 1
            } else if value < 0 {
                mappedValue = -1
            }
            
            currentTimeSequence.observe(mappedValue)
        }
        
        playerStateSequence.wait(timeout: 10, enforceOrder: true)
        currentTimeSequence.wait(timeout: 10, enforceOrder: true)
    }
    
    func testStopTrack() async throws {
        
        let tracks = setupTracks(showMediaInfoUseCase: showMediaInfoUseCase)
        let track = tracks.first!
        
        let playerStateSequence = AssertSequence(testCase: self, values: [PlayerState.playing, PlayerState.none])
        
        let currentTimeSequence = AssertSequence(testCase: self, values: [1])
        
        let trackIdSequence = AssertSequence(testCase: self, values: [trackIdSequence, nil])
        
        let resultPlay = await audioService.play(
            mediaInfo: track,
            data: Data()
        )
        try AssertResultSucceded(resultPlay)
        
        let resultStop = await audioService.stop()
        try AssertResultSucceded(resultStop)
        
        currentPlayerStateUseCase.info.observe(on: self, observerBlock: trackIdSequence.observe)
        currentPlayerStateUseCase.state.observe(on: self, observe: playerStateSequence.observe)
        currentPlayerStateUseCase.currentTime.observe(on: self) { value in
            
            var mappedValue = value

            if value > 0 {
                mappedValue = 1
            } else if value < 0 {
                mappedValue = -1
            }
            
            currentTimeSequence.observe(mappedValue)
        }
        
        playerStateSequence.wait(timeout: 10, enforceOrder: true)
        currentTimeSequence.wait(timeout: 10, enforceOrder: true)
    }
    
    func testChangeTrack() async throws {
        
        let tracks = setupTracks(showMediaInfoUseCase: showMediaInfoUseCase)
        let track = tracks.first!
        
        let track2 = tracks.first!

        let playerStateSequence = AssertSequence(testCase: self, values: [PlayerState.playing, PlayerState.playing])
        let currentTimeSequence = AssertSequence(testCase: self, values: [1])
        let trackIdSequence = AssertSequence(testCase: self, values: [track.id, track2.id])
        
        let resultPlay = await audioService.play(
            mediaInfo: track,
            data: Data()
        )
        try AssertResultSucceded(resultPlay)
        
        
        let resultPlay2 = await audioService.play(
            mediaInfo: track2,
            data: Data()
        )
        try AssertResultSucceded(resultPlay2)
        
        currentPlayerStateUseCase.info.observe(on: self, observerBlock: trackIdSequence.observe)
        currentPlayerStateUseCase.state.observe(on: self, observe: playerStateSequence.observe)
        currentPlayerStateUseCase.currentTime.observe(on: self) { value in
            
            var mappedValue = value

            if value > 0 {
                mappedValue = 1
            } else if value < 0 {
                mappedValue = -1
            }
            
            currentTimeSequence.observe(mappedValue)
        }
        
        playerStateSequence.wait(timeout: 10, enforceOrder: true)
        currentTimeSequence.wait(timeout: 10, enforceOrder: true)
    }
}

// MARK: - Mocks

enum PlayerState {
    
    case playing
    case paused
    case none
}

fileprivate class AudioServiceMock: AudioPlayerService {
    
    public var persistentTrackId: Observable<String?> = Observable(nil)
    public var isPlaying = Observable(false)
    public var currentTime = Observable(0.0)
    public var volume = Observable(0.0)
    
    func play(mediaInfo: MediaInfo, data: Data) async -> Result<Void, Error> {
        
        persistentTrackId.value = mediaInfo.id
        isPlaying.value = true
        
        return .success(())
    }
    
    func pause() async -> Result<Void, Error> {
        
        isPlaying.value = false
        
        return .success(())
    }
    
    func stop() async -> Result<Void, Error> {
        
        isPlaying.value = false
        persistentTrackId.value = nil
        
        return .success(())
    }
    
    func seek(time: Double) async -> Result<Void, Error> {
        
        currentTime.value = time
        return .success(())
    }
    
    func setVolume(value: Double) async -> Result<Void, Error> {
        
        volume.value = value
        return .success(())
    }
}


fileprivate class ShowMediaInfoUseCaseMock: ShowMediaInfoUseCase {

    public var tracks = [UUID: MediaInfo]()
    
    func fetchInfo(trackId: UUID) async -> Result<MediaInfo, ShowMediaInfoUseCaseError> {
        
        guard let trackData = tracks[trackId] else {
            return .failure(.trackNotFound)
        }
        
        return .success(trackData)
    }
}

class AssertSequence<T: Equatable> {
    
    private enum ExpectationItem {
        
        case withoutValue(expectation: XCTestExpectation)
        case withValue(expectation: XCTestExpectation, value: T)
    }
    
    private unowned var testCase: XCTestCase
    private var items: [ExpectationItem] = []
    private var currentIndex = 0
    
    init(testCase: XCTestCase, values: [T] = []) {
        
        self.testCase = testCase
        
        addExpectations(values: values)
    }
    
    func addExpectation(value: T) {

        let index = items.count
        let expectation = testCase.expectation(description: "Expectation\(index) value = \(value)")
        items.append(.withValue(expectation: expectation, value: value))
    }
    
    func addExpectation() {

        let index = items.count
        let expectation = testCase.expectation(description: "Expectation\(index)")
        items.append(.withoutValue(expectation: expectation))
    }
    
    func addExpectations(values: [T]) {
        
        values.forEach { value in
            addExpectation(value: value)
        }
    }
    
    func wait(timeout: Double, enforceOrder: Bool) {
        
        let mappedExpectations = items.map { item -> XCTestExpectation in

            switch item {
            case .withValue(expectation: let expectation, value: _):
                return expectation
                
            case .withoutValue(expectation: let expectation):
                return expectation
            }
        }
        
        testCase.wait(for: mappedExpectations, timeout: timeout, enforceOrder: enforceOrder)
    }
    
    func observe(value: T) {
        
        let item = items[currentIndex]
        
        switch item {
        case .withValue(expectation: let expectation, value: let expectedValue):
            
            if value == expectedValue {
                expectation.fulfill()
            }
        default:
            fatalError()
        }
        
        currentIndex += 1
    }
}
