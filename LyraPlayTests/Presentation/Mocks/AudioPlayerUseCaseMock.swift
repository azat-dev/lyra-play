//
//  PlayerControlUseCaseMock.swift
//  LyraPlayTests
//
//  Created by Azat Kaiumov on 01.07.22.
//

import Foundation
import LyraPlay

class PlayerControlUseCaseMock: PlayerControlUseCase {

    private var currentTrackId: UUID? = nil
    private var currentPlayerStateUseCase: CurrentPlayerStateUseCaseMock?
    
    public init(currentPlayerStateUseCase: CurrentPlayerStateUseCaseMock? = nil) {
        
        self.currentPlayerStateUseCase = currentPlayerStateUseCase
    }
    
    func play(trackId: UUID) async -> Result<Void, PlayerControlUseCaseError> {
        
        currentTrackId = trackId
        await currentPlayerStateUseCase?.setTrack(trackId: trackId)
        currentPlayerStateUseCase?.state.value = .playing
        return .success(())
    }
    
    func pause() async -> Result<Void, PlayerControlUseCaseError> {
        
        guard  currentTrackId != nil else {
            return .failure(.noActiveTrack)
        }
        
        currentPlayerStateUseCase?.state.value = .paused
        return .success(())
    }
}
