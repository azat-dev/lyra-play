//
//  FinishedPlayMediaWithSubtitlesUseStateControllerImpl.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 20.02.23.
//

import Foundation

public class FinishedPlayMediaWithSubtitlesUseStateController: PausedPlayMediaWithSubtitlesUseStateController {
    
    public override func resume() -> Result<Void, PlayMediaWithSubtitlesUseCaseError> {
        
        return super.play(atTime: 0)
    }
    
    public override func togglePlay() -> Result<Void, PlayMediaWithSubtitlesUseCaseError> {
        
        return super.resume()
    }
}
