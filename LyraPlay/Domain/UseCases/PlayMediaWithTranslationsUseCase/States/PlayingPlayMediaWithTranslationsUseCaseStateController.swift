//
//  PlayingPlayMediaWithTranslationsUseCaseStateController.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 22.02.2023.
//

import Foundation
import Combine

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
    
    deinit {
        
        guard session.playMediaUseCase.delegate === self else {
            return
        }
        
        session.playMediaUseCase.delegate = nil
    }
    
    // MARK: - Methods
    
    public override func pause() -> Result<Void, PlayMediaWithTranslationsUseCaseError> {
        
        guard let delegate = delegate else {
            return .failure(.internalError(nil))
        }
        
        // FIXME: 
        return delegate.pause(
            elapsedTime: 0,
            session: session
        )
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
    
    public override func setTime(_ time: TimeInterval) {
        
        session.playMediaUseCase.setTime(time)
    }
    
    public func runResumePlaying() -> Result<Void, PlayMediaWithTranslationsUseCaseError> {
        
        session.playMediaUseCase.delegate = self

        let playResult = session.playMediaUseCase.resume()
        
        guard case .success = playResult else {
            return playResult.mapResult()
        }

        delegate?.didResumePlaying(withController: self)
        return .success(())
    }
    
    public func runPlaying(atTime: TimeInterval) -> Result<Void, PlayMediaWithTranslationsUseCaseError> {
        
        session.playMediaUseCase.delegate = self
        
        let playResult = session.playMediaUseCase.play(atTime: atTime)
        
        guard case .success = playResult else {
            return playResult.mapResult()
        }

        delegate?.didStartPlaying(withController: self)
        return .success(())
    }
}

// MARK: - PlayMediaWithSubtitlesUseCaseDelegate

extension PlayingPlayMediaWithTranslationsUseCaseStateController: PlayMediaWithSubtitlesUseCaseDelegate {
    
    public func playMediaWithSubtitlesUseCaseWillChange(
        from fromPosition: SubtitlesPosition?,
        to: SubtitlesPosition?,
        interrupt stopPlaying: inout Bool
    ) {
        
        guard
            let fromPosition = fromPosition,
            let translationsData = session.provideTranslationsToPlayUseCase.getTranslationsToPlay(for: fromPosition)
        else {
            return
        }
        
        stopPlaying = true
        
        Task {
            
            let _ = await delegate?.pronounce(
                translationData: translationsData,
                session: session
            )
        }
    }
}
