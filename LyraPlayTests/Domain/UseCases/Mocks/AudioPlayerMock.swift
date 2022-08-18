//
//  AudioPlayerMock.swift
//  LyraPlayTests
//
//  Created by Azat Kaiumov on 05.07.22.
//

import Foundation
import Combine

import LyraPlay

class AudioPlayerMock: AudioPlayer {
    
    public var state: CurrentValueSubject<AudioPlayerState, Never> = .init(.initial)
    
    public var currentTime = Observable(0.0)
    
    public var currentFileId: String?
    
    func prepare(fileId: String, data trackData: Data) -> Result<Void, AudioPlayerError> {
        
        currentFileId = fileId
        return .success(())
    }
    
    func play() -> Result<Void, AudioPlayerError> {
        
        guard let currentFileId = currentFileId else {
            return .failure(.noActiveFile)
        }

        self.state.value = .playing(session: .init(fileId: currentFileId))
        return .success(())
    }
    
    func play(atTime: TimeInterval) -> Result<Void, AudioPlayerError> {
        
        return play()
    }

    
    func playAndWaitForEnd() async -> Result<Void, AudioPlayerError> {
        
        guard let currentFileId = currentFileId else {
            return .failure(.noActiveFile)
        }
        
        self.state.value = .playing(session: .init(fileId: currentFileId))
        self.state.value = .finished(session: .init(fileId: currentFileId))
        return .success(())
    }
    
    func playAndWaitForEnd() -> AsyncThrowingStream<AudioPlayerState, Error> {
        
        return AsyncThrowingStream { continuation in
        
            guard let currentFileId = currentFileId else {
                continuation.finish(throwing: AudioPlayerError.noActiveFile)
                return
            }
            
            continuation.yield(.playing(session: .init(fileId: currentFileId)))
            continuation.yield(.finished(session: .init(fileId: currentFileId)))
            continuation.finish()
        }
    }
    
    
    
    func pause() -> Result<Void, AudioPlayerError> {
        
        switch self.state.value {
            
        case .stopped, .initial, .loaded:
            
            return .failure(.noActiveFile)
            
        case .paused(let session, _), .playing(let session):
            
            self.state.value = .paused(session: session, time: currentTime.value)
            return .success(())
            
        case .finished:
            return .success(())
        }
    }
    
    func stop() -> Result<Void, AudioPlayerError> {
        
        self.state.value = .stopped
        return .success(())
    }
}
