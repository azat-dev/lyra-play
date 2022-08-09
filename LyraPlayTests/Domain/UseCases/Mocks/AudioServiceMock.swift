//
//  AudioServiceMock.swift
//  LyraPlayTests
//
//  Created by Azat Kaiumov on 05.07.22.
//

import Foundation
import LyraPlay

class AudioServiceMock: AudioService {
    
    
    public var state: Observable<AudioServiceState> = .init(.initial)
    
    public var currentTime = Observable(0.0)
    
    
    func play(fileId: String, data: Data) async -> Result<Void, AudioServiceError> {
        
        self.state.value = .playing(data: .init(fileId: fileId))
        return .success(())
    }
    
    func pause() async -> Result<Void, AudioServiceError> {
        
        switch self.state.value {
            
        case .stopped, .initial:
            
            return .failure(.noActiveFile)
            
        case .paused(let stateData, _), .playing(let stateData), .interrupted(let stateData, _):
            
            self.state.value = .paused(data: stateData, time: currentTime.value)
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
