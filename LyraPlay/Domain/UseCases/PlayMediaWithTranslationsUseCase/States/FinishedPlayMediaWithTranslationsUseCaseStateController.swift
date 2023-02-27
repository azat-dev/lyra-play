//
//  FinishedPlayMediaWithTranslationsUseCaseStateController.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 26.02.23.
//

import Foundation

public final class FinishedPlayMediaWithTranslationsUseCaseStateController: PausedPlayMediaWithTranslationsUseCaseStateController {
    
    public override func resume() -> Result<Void, PlayMediaWithTranslationsUseCaseError> {
        
        guard let delegate = delegate else {
            return .failure(.internalError(nil))
        }
        
        return delegate.play(atTime: 0, session: session)
    }
    
    public override func togglePlay() -> Result<Void, PlayMediaWithTranslationsUseCaseError> {
        
        return resume()
    }
}
