//
//  PausedPlayMediaWithSubtitlesUseStateControllerImpl.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 20.02.23.
//

import Foundation

public class PausedPlayMediaWithSubtitlesUseStateControllerImpl: PlayingPlayMediaWithSubtitlesUseStateControllerImpl, PausedPlayMediaWithSubtitlesUseStateController {
    
    // MARK: - Methods

    public override func play() -> Result<Void, PlayMediaWithSubtitlesUseCaseError> {
    
        guard let delegate = delegate else {
            return .failure(.internalError(nil))
        }
        
        return delegate.play(session: session)
    }
    
    public override func togglePlay() -> Result<Void, PlayMediaWithSubtitlesUseCaseError> {
        
        return play()
    }
    
    public override func run() -> Result<Void, PlayMediaWithSubtitlesUseCaseError> {
        
        guard let delegate = delegate else {
            return .failure(.internalError(nil))
        }
        
        let result = session.playMediaUseCase.pause()
        
        guard case .success = result else {
            return result.mapResult()
        }
        
        session.playSubtitlesUseCase?.pause()
        delegate.didPause(session: session)
        
        return .success(())
    }
}
