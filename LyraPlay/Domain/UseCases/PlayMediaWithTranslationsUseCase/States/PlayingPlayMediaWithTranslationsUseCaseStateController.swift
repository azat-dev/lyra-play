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
    
    private func pronounceCurrentTranslationItem(_ translations: TranslationsToPlayData) -> AsyncThrowingStream<PronounceTranslationsUseCaseState, Error> {
        
        switch translations {
            
        case .single(let translation):
            return session.pronounceTranslationsUseCase.pronounceSingle(translation: translation)
            
        case .groupAfterSentence(let translations):
            return session.pronounceTranslationsUseCase.pronounceGroup(translations: translations)
        }
    }
    
    private func playTranslationAfterSubtitlesPositionChange(_ data: WillChangeSubtitlesPositionData) {

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
    
    public func playMediaWithSubtitlesUseCaseWillChange(from: SubtitlesPosition?, to: SubtitlesPosition?, stop: inout Bool) {
        
    }
    
    public func playMediaWithSubtitlesUseCaseDidChange(position: SubtitlesPosition?) {
    
    }
    
    public func playMediaWithSubtitlesUseCaseDidFinish() {
        
    }
}
