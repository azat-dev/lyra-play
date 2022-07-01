//
//  AudioPlayerUseCaseMock.swift
//  LyraPlayTests
//
//  Created by Azat Kaiumov on 01.07.22.
//

import Foundation
import LyraPlay

class AudioPlayerUseCaseMock: AudioPlayerUseCase {

    private var currentTrackId: UUID? = nil

    var isPlaying = Observable(false)
    
    func setTrack(fileId: UUID) async -> Result<Void, AudioPlayerUseCaseError> {
            
        currentTrackId = fileId
        return .success(())
    }
    
    func getCurrentTrackId() async -> Result<UUID?, AudioPlayerUseCaseError> {
        return .success(currentTrackId)
    }
    
    func play() async -> Result<Void, AudioPlayerUseCaseError> {
        
        isPlaying.value = true
        return .success(())
    }
    
    func pause() async -> Result<Void, AudioPlayerUseCaseError> {
        
        isPlaying.value = false
        return .success(())
    }
}
