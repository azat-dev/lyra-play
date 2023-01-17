//
//  PlayMediaUseCaseMock.swift
//  LyraPlayTests
//
//  Created by Azat Kaiumov on 01.07.22.
//

import Foundation
import Combine

import LyraPlay

final class PlayMediaUseCaseMockStateble: PlayMediaUseCase {
    
    private var currentTrackId: UUID? = nil
    var state = CurrentValueSubject<PlayMediaUseCaseState, Never>(.initial)
    
    public init() {}
    
    var prepareWillReturn: ((_ mediaId: UUID) -> Result<Void, PlayMediaUseCaseError>)?
    
    func prepare(mediaId: UUID) -> Result<Void, PlayMediaUseCaseError> {
        
        if let prepareWillReturn = prepareWillReturn {
            
            let result = prepareWillReturn(mediaId)
            
            if case .success =  result {
                currentTrackId  = mediaId
            }
            
            return result
        }
        
        currentTrackId = mediaId
        self.state.value = .loading(mediaId: mediaId)
        self.state.value = .loaded(mediaId: mediaId)
        
        return .success(())
    }
    
    func play() -> Result<Void, PlayMediaUseCaseError> {
        
        guard let currentTrackId = currentTrackId else {
            return .failure(.noActiveTrack)
        }
        
        self.state.value = .playing(mediaId: currentTrackId)
        
        return .success(())
    }
    
    func play(atTime: TimeInterval) -> Result<Void, PlayMediaUseCaseError> {
        
        guard let currentTrackId = currentTrackId else {
            return .failure(.noActiveTrack)
        }
        
        self.state.value = .playing(mediaId: currentTrackId)
        
        return .success(())
    }
    
    func pause() -> Result<Void, PlayMediaUseCaseError> {
        
        guard  currentTrackId != nil else {
            return .failure(.noActiveTrack)
        }
        
        state.value = .paused(mediaId: currentTrackId!, time: 0)
        return .success(())
    }
    
    func stop() -> Result<Void, PlayMediaUseCaseError> {
        
        currentTrackId = nil
        state.value = .stopped
        
        return .success(())
    }
    
    func finish() {
        
        guard let currentTrackId = currentTrackId else {
            fatalError("No active track")
        }
        
        self.state.value = .finished(mediaId: currentTrackId)
    }
    
    func togglePlay() -> Result<Void, PlayMediaUseCaseError> {
        
        fatalError()
    }
}
