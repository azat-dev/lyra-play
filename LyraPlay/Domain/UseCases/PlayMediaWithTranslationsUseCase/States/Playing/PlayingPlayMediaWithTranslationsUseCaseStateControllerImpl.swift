//
//  PlayingPlayMediaWithTranslationsUseCaseStateControllerImpl.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 22.02.2023.
//

import Foundation

public final class PlayingPlayMediaWithTranslationsUseCaseStateControllerImpl: LoadedPlayMediaWithTranslationsUseCaseStateControllerImpl, PlayingPlayMediaWithTranslationsUseCaseStateController {
    
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
    
    public func run(
        session: PlayMediaWithTranslationsUseCaseStateControllerActiveSession,
        delegate: PlayMediaWithTranslationsUseCaseStateControllerDelegate
    ) -> Result<Void, PlayMediaWithTranslationsUseCaseError> {
        
        guard case .activeSession(_, .loaded(let subtitlesState, _)) = session.playMediaUseCase.state.value else {
            return .failure(.internalError(nil))
        }
        
        let playResult = session.playMediaUseCase.play()
        
        guard case .success = playResult else {
            return playResult.mapResult()
        }

        fatalError()
    }
}
