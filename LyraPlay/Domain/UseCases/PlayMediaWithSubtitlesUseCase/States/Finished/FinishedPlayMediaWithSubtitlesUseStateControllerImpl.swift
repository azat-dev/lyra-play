//
//  FinishedPlayMediaWithSubtitlesUseStateControllerImpl.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 20.02.23.
//

import Foundation

public class FinishedPlayMediaWithSubtitlesUseStateControllerImpl: PausedPlayMediaWithSubtitlesUseStateControllerImpl, FinishedPlayMediaWithSubtitlesUseStateController {
    
    public override func play() -> Result<Void, PlayMediaWithSubtitlesUseCaseError> {
        
        return super.play(atTime: 0)
    }    
}
