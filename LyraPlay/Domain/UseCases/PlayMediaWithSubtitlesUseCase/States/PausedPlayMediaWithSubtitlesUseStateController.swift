//
//  PausedPlayMediaWithSubtitlesUseStateControllerImpl.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 20.02.23.
//

import Foundation

public class PausedPlayMediaWithSubtitlesUseStateController: LoadedPlayMediaWithSubtitlesUseStateController {
    
    // MARK: - Methods

    public override func play(atTime: TimeInterval) -> Result<Void, PlayMediaWithSubtitlesUseCaseError> {
    
        guard let delegate = delegate else {
            return .failure(.internalError(nil))
        }
        
        return delegate.play(atTime: atTime, session: session)
    }
    
    public override func resume() -> Result<Void, PlayMediaWithSubtitlesUseCaseError> {
        
        guard let delegate = delegate else {
            return .failure(.internalError(nil))
        }
        
        return delegate.resumePlaying(session: session)
    }
    
    public override func togglePlay() -> Result<Void, PlayMediaWithSubtitlesUseCaseError> {
        
        return resume()
    }
    
    public override func setTime(_ time: TimeInterval) {
        
        session.playMediaUseCase.setTime(time)
        session.playSubtitlesUseCase?.setTime(time)
    }
    
    public func runPausing() -> Result<Void, PlayMediaWithSubtitlesUseCaseError> {
        
        let result = session.playMediaUseCase.pause()
        
        guard case .success = result else {
            return result.mapResult()
        }
        
        session.playSubtitlesUseCase?.pause()
        delegate?.didPause(controller: self)
        
        return .success(())
    }
}
