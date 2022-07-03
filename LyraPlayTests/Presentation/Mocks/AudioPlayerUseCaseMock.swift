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

    var isPlaying = Observable(false)
    
    func setTrack(fileId: UUID) async -> Result<Void, PlayerControlUseCaseError> {
            
        currentTrackId = fileId
        return .success(())
    }
    
    func getCurrentTrackId() async -> Result<UUID?, PlayerControlUseCaseError> {
        return .success(currentTrackId)
    }
    
    func play() async -> Result<Void, PlayerControlUseCaseError> {
        
        isPlaying.value = true
        return .success(())
    }
    
    func pause() async -> Result<Void, PlayerControlUseCaseError> {
        
        isPlaying.value = false
        return .success(())
    }
}
