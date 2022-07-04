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
    
    private var currentPlayerStateUseCase: CurrentPlayerStateUseCase!
    private var audioService: AudioServiceMock!
    private var showMediaInfoUseCase: ShowMediaInfoUseCaseMock!
    
    override func setUp() {
        
        showMediaInfoUseCase = ShowMediaInfoUseCaseMock()
        audioService = AudioServiceMock()
        
        currentPlayerStateUseCase = DefaultCurrentPlayerStateUseCase(
            audioService: audioService,
            showMediaInfoUseCase: showMediaInfoUseCase
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
    
    func testPlayTrack() async throws {
    
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
        sleep(1)

        
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

// MARK: - Mocks

fileprivate class AudioServiceMock: AudioService {
    
    public var fileId: Observable<String?> = Observable(nil)
    
    public var isPlaying = Observable(false)
    
    public var currentTime = Observable(0.0)
    
    public var volume = Observable(0.0)

    
    func play(fileId: String, data: Data) async -> Result<Void, Error> {
    
        self.fileId.value = fileId
        isPlaying.value = true
        
        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 1) { [weak self] in
            
            guard
                let self = self,
                self.isPlaying.value
            else {
                return
            }
            
            
            self.currentTime.value += 1
        }
        
        return .success(())
    }
    
    func pause() async -> Result<Void, Error> {
        
        isPlaying.value = false
        
        return .success(())
    }
    
    func stop() async -> Result<Void, Error> {
        
        fileId.value = nil
        isPlaying.value = false
        
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
    
    private struct ExpectationItem {
        var expectation: XCTestExpectation?
        var value: T
    }
    
    private unowned var testCase: XCTestCase
    private var expectedValues: [T] = [] {
        didSet {
            expectation.expectedFulfillmentCount = expectedValues.count
        }
    }
    
    private var receivedValues = [T]()
    private var expectation = XCTestExpectation()
    
    
    init(testCase: XCTestCase, values: [T] = []) {
        
        self.testCase = testCase
        
        addExpectations(values: values)
    }
    
    func addExpectation(value: T) {

        expectedValues.append(value)
    }
    
    func addExpectations(values: [T]) {
        
        values.forEach { value in
            addExpectation(value: value)
        }
    }

    func observe(_ observable: Observable<T>, file: StaticString = #filePath, line: UInt = #line) {
        
        observe(observable, mapper: { $0 }, file: file, line: line)
    }
    
    func observe<X>(_ observable: Observable<X>, mapper: @escaping (X) -> T, file: StaticString = #filePath, line: UInt = #line) {
        
        
        observable.observe(on: self) { [weak self] value in
            
            guard let self = self else {
                return
            }
            
            let mappedValue = mapper(value)
            
            self.receivedValues.append(mappedValue)
            self.expectation.fulfill()
        }
    }
    
    func wait(timeout: TimeInterval, enforceOrder: Bool, file: StaticString = #filePath, line: UInt = #line) {
        
        if !enforceOrder {
            fatalError("Not implemented")
        }
        
        testCase.wait(for: [expectation], timeout: timeout, enforceOrder: enforceOrder)
        XCTAssertEqual(receivedValues, expectedValues, file: file, line: line)
    }
}
