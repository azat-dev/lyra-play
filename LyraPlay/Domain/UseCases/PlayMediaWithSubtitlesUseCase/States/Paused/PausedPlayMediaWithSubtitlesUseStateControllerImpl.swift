//
//  PausedPlayMediaWithSubtitlesUseStateControllerImpl.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 20.02.23.
//

import Foundation

public class PausedPlayMediaWithSubtitlesUseStateControllerImpl: PlayingPlayMediaWithSubtitlesUseStateControllerImpl, PausedPlayMediaWithSubtitlesUseStateController {
    
    // MARK: - Methods
    
    public override func run() -> Result<Void, PlayMediaWithSubtitlesUseCaseError> {
        return .failure(.internalError(nil))
    }
}
