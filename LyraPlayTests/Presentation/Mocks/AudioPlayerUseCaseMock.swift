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
    private var currentPlayerStateUseCase: CurrentPlayerStateUseCase
    
    func play(trackId: UUID) async -> Result<Void, PlayerControlUseCaseError> {
        
        currentTrackId = trackId
        return .success(())
    }
    
    func pause() async -> Result<Void, PlayerControlUseCaseError> {
        
        guard  currentTrackId != nil else {
            return .failure(.noActiveTrack)
        }
        
        return .success(())
    }
}
