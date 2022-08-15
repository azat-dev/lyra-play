//
//  AudioServiceMock.swift
//  LyraPlayTests
//
//  Created by Azat Kaiumov on 05.07.22.
//

import Foundation
import Combine

import LyraPlay

class AudioServiceMock: AudioService {
    
    
    public var state: CurrentValueSubject<AudioServiceState, Never> = .init(.initial)
    
    public var currentTime = Observable(0.0)
    
    public var currentFileId: String?
    
    func prepare(fileId: String, data trackData: Data) async -> Result<Void, AudioServiceError> {
        
        currentFileId = fileId
        return .success(())
    }
    
    func play() async -> Result<Void, AudioServiceError> {
        
        guard let currentFileId = currentFileId else {
            return .failure(.noActiveFile)
        }

        self.state.value = .playing(session: .init(fileId: currentFileId))
        return .success(())
    }
    
    func play(atTime: TimeInterval) async -> Result<Void, AudioServiceError> {
        
        return await play()
    }

    
    func playAndWaitForEnd() async -> Result<Void, AudioServiceError> {
        
        guard let currentFileId = currentFileId else {
            return .failure(.noActiveFile)
        }
        
        self.state.value = .playing(session: .init(fileId: currentFileId))
        self.state.value = .finished(session: .init(fileId: currentFileId))
        return .success(())
    }
    
    func pause() async -> Result<Void, AudioServiceError> {
        
        switch self.state.value {
            
        case .stopped, .initial, .loaded:
            
            return .failure(.noActiveFile)
            
        case .paused(let session, _), .playing(let session), .interrupted(let session, _):
            
            self.state.value = .paused(session: session, time: currentTime.value)
            return .success(())
            
        case .finished:
            return .success(())
        }
    }
    
    func stop() async -> Result<Void, AudioServiceError> {
        
        self.state.value = .stopped
        return .success(())
    }
}
