//
//  FinishedPlayMediaUseCaseStateController.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 15.02.23.
//

import Foundation

public final class FinishedPlayMediaUseCaseStateController: PausedPlayMediaUseCaseStateController {
    
    public override func togglePlay() -> Result<Void, PlayMediaUseCaseError> {
        return play(atTime: 0)
    }
    
    public override func setTime(_ time: TimeInterval) {
        
        guard time < audioPlayer.duration else {
            return
        }
        
        audioPlayer.setTime(time)
        
        delegate?.pause(
            mediaId: mediaId,
            audioPlayer: audioPlayer
        )
    }
}
