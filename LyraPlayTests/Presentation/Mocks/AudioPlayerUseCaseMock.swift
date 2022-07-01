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
    
    func setTrack(fileId: UUID) async -> Result<Void, AudioPlayerUseCaseError> {
        
        return await withCheckedContinuation { contiuation in
            
        }
    }
    
    func getCurrentTrackId() async -> Result<UUID?, AudioPlayerUseCaseError> {
        return .success(currentTrackId)
    }
    
    func play() async -> Result<Void, AudioPlayerUseCaseError> {
        return .success(())
    }
    
    func pause() async -> Result<Void, AudioPlayerUseCaseError> {
        return .success(())
    }
}
