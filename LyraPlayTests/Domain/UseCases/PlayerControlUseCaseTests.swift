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

    private var useCase: PlayerControlUseCase!
    private var audioService: AudioServiceMock!
    private var loadTrackUseCase: LoadTrackUseCaseMock!
    
    override func setUp() async throws {
        
        audioService = AudioServiceMock()
        loadTrackUseCase = LoadTrackUseCaseMock()
        
        useCase = DefaulPlayerControlUseCase(
            audioService: audioService,
            loadTrackUseCase: loadTrackUseCase
        )
    }
    
    func testPlayNotExistingTrack() async throws {
        
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

        setUpTracks(loadTrackUseCase: loadTrackUseCase)
        
        let track = loadTrackUseCase.tracks.first!
        let trackId = track.0
        
        let trackIdSequence = AssertSequence(testCase: self, values: [nil, trackId.uuidString])
        
        trackIdSequence.observe(audioService.fileId)
        
        let result = await useCase.play(trackId: trackId)
        try AssertResultSucceded(result)
        
        trackIdSequence.wait(timeout: 3, enforceOrder: true)
    }
}

fileprivate class LoadTrackUseCaseMock: LoadTrackUseCase {
    
    public var tracks = [UUID: Data]()
    
    func load(trackId: UUID) async -> Result<Data, LoadTrackUseCaseError> {
        
        guard let data = tracks[trackId] else {
            return .failure(.trackNotFound)
        }
        
        return .success(data)
    }
}
