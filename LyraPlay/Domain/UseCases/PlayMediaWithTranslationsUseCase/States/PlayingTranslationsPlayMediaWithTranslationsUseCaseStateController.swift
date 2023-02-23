//
//  PlayingTranslationsPlayMediaWithTranslationsUseCaseStateController.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 23.02.23.
//

import Foundation

public final class PlayingTranslationsPlayMediaWithTranslationsUseCaseStateController: PlayMediaWithTranslationsUseCaseStateController {
    
    // MARK: - Properties
    
    private let translations: TranslationsToPlay
    private let session: PlayMediaWithTranslationsUseCaseStateControllerActiveSession
    private weak var delegate: PlayMediaWithTranslationsUseCaseStateControllerDelegate?
    
    // MARK: - Initializers
    
    public init(
        translations: TranslationsToPlay,
        session: PlayMediaWithTranslationsUseCaseStateControllerActiveSession,
        delegate: PlayMediaWithTranslationsUseCaseStateControllerDelegate
    ) {
        
        self.translations = translations
        self.session = session
        self.delegate = delegate
    }
    
    // MARK: - Methods
    
    public func pause() -> Result<Void, PlayMediaWithTranslationsUseCaseError> {
        
        guard let delegate = delegate else {
            return .failure(.internalError(nil))
        }
        
        return delegate.pause(session: session)
    }
    
    public func prepare(session: PlayMediaWithTranslationsSession) async -> Result<Void, PlayMediaWithTranslationsUseCaseError> {
        
        guard let delegate = delegate else {
            return .failure(.internalError(nil))
        }
        
        return await delegate.load(session: session)
    }
    
    public func play() -> Result<Void, PlayMediaWithTranslationsUseCaseError> {
        return .success(())
    }
    
    public func play(atTime: TimeInterval) -> Result<Void, PlayMediaWithTranslationsUseCaseError> {
        
        return .success(())
    }
    
    public func stop() -> Result<Void, PlayMediaWithTranslationsUseCaseError> {
        
        session.pronounceTranslationsUseCase.stop()
        return .success(())
    }
    
    public func togglePlay() -> Result<Void, PlayMediaWithTranslationsUseCaseError> {
        return pause()
    }
    
    private func pronounceCurrentTranslationItem(_ translations: TranslationsToPlayData) -> AsyncThrowingStream<PronounceTranslationsUseCaseState, Error> {
        
        switch translations {
            
        case .single(let translation):
            return session.pronounceTranslationsUseCase.pronounceSingle(translation: translation)
            
        case .groupAfterSentence(let translations):
            return session.pronounceTranslationsUseCase.pronounceGroup(translations: translations)
        }
    }
    
    public func run() async throws -> Result<Void, PlayMediaWithTranslationsUseCaseError> {
        
        for try await pronounciationState in pronounceCurrentTranslationItem(translations.data) {
            
            switch pronounciationState {
            
            case .stopped, .paused:
                return .success(())

            case .finished, .loading:
                continue
                
            case .playing(let stateData):
                continue
            }
        }
        
        return .success(())
    }
}

// MARK: - PlayMediaWithSubtitlesUseCaseDelegate

extension PlayingTranslationsPlayMediaWithTranslationsUseCaseStateController: PlayMediaWithSubtitlesUseCaseDelegate {
    
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
