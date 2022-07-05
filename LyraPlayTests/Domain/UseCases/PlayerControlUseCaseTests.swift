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
    private var loadTrackUseCase: LoadTrackUseCase!
    
    override func setUp() async throws {
        
        audioService = AudioServiceMock()
        audioFileLoader = AudioFileLoader()
        loadTrackUseCase = LoadTrackUseCaseMock()
        
        useCase = DefaultAudioPlayerControlUseCase(
            audioService: audioService,
            audioLoader: audioFileLoader,
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
