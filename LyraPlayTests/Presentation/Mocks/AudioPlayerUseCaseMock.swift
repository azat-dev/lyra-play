//
//  PlayMediaUseCaseMock.swift
//  LyraPlayTests
//
//  Created by Azat Kaiumov on 01.07.22.
//

import Foundation
import LyraPlay

final class PlayMediaUseCaseMock: PlayMediaUseCase {
    
    private var currentTrackId: UUID? = nil
    private var currentPlayerStateUseCase: CurrentPlayerStateUseCaseMock?
    var state: Observable<PlayMediaUseCaseState> = .init(.initial)
    
    public init(currentPlayerStateUseCase: CurrentPlayerStateUseCaseMock? = nil) {
        
        self.currentPlayerStateUseCase = currentPlayerStateUseCase
    }
    
    func play(mediaId: UUID) async -> Result<Void, PlayMediaUseCaseError> {
        
        currentTrackId = mediaId
        self.state.value = .loading(mediaId: mediaId)
        self.state.value = .loaded(mediaId: mediaId)
        
        await currentPlayerStateUseCase?.setTrack(trackId: mediaId)
        currentPlayerStateUseCase?.state.value = .playing
        
        self.state.value = .playing(mediaId: mediaId)
        return .success(())
    }
    
    func pause() async -> Result<Void, PlayMediaUseCaseError> {
        
        guard  currentTrackId != nil else {
            return .failure(.noActiveTrack)
        }
        
        currentPlayerStateUseCase?.state.value = .paused
        state.value = .paused(mediaId: currentTrackId!, time: 0)
        return .success(())
    }
    
    func stop() async -> Result<Void, PlayMediaUseCaseError> {
        
        currentTrackId = nil
        state.value = .stopped
        
        return .success(())
    }
}
