//
//  FinishedPlayMediaUseCaseStateController.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 15.02.23.
//

import Foundation

public final class FinishedPlayMediaUseCaseStateControllerImpl: PausedPlayMediaUseCaseStateControllerImpl, FinishedPlayMediaUseCaseStateController {
    
    public override func play() -> Result<Void, PlayMediaUseCaseError> {
        
        guard let delegate = delegate else {
            return .failure(.internalError(nil))
        }
        
        return delegate.play(
            atTime: 0,
            mediaId: mediaId,
            audioPlayer: audioPlayer
        )
    }
    
    public override func togglePlay() -> Result<Void, PlayMediaUseCaseError> {
        return play()
    }
}
