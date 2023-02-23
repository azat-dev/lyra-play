//
//  PlayingPlayMediaWithTranslationsUseCaseStateController.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 22.02.2023.
//

import Foundation

public final class PlayingPlayMediaWithTranslationsUseCaseStateController: LoadedPlayMediaWithTranslationsUseCaseStateController {
    
    // MARK: - Initializers
    
    public override init(
        session: PlayMediaWithTranslationsUseCaseStateControllerActiveSession,
        delegate: PlayMediaWithTranslationsUseCaseStateControllerDelegate
    ) {
        
        super.init(
            session: session,
            delegate: delegate
        )
    }
    
    // MARK: - Methods
    
    public override func pause() -> Result<Void, PlayMediaWithTranslationsUseCaseError> {
        
        guard let delegate = delegate else {
            return .failure(.internalError(nil))
        }
        
        return delegate.pause(session: session)
    }
    
    public override func togglePlay() -> Result<Void, PlayMediaWithTranslationsUseCaseError> {
        return pause()
    }
    
    public override func stop() -> Result<Void, PlayMediaWithTranslationsUseCaseError> {
        
        guard let delegate = delegate else {
            return .failure(.internalError(nil))
        }
        
        return delegate.stop(activeSession: session)
    }
    
    public func run() -> Result<Void, PlayMediaWithTranslationsUseCaseError> {
        
        session.playMediaUseCase.delegate = self
        
        let playResult = session.playMediaUseCase.play()
        
        guard case .success = playResult else {
            return playResult.mapResult()
        }

        return .success(())
    }
}

// MARK: - PlayMediaWithSubtitlesUseCaseDelegate

extension PlayingPlayMediaWithTranslationsUseCaseStateController: PlayMediaWithSubtitlesUseCaseDelegate {
    
    public func playMediaWithSubtitlesUseCaseWillChange(
        from fromPosition: SubtitlesPosition?,
        to: SubtitlesPosition?,
        stop stopPlaying: inout Bool
    ) {
        
        guard
            let fromPosition = fromPosition,
            let translationsData = session.provideTranslationsToPlayUseCase.getTranslationsToPlay(for: fromPosition)
        else {
            return
        }
        
        stopPlaying = true
        
        let _ = delegate?.pronounce(
            translationData: translationsData,
            session: session
        )
    }
}
