//
//  PlayingTranslationsPlayMediaWithTranslationsUseCaseStateController.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 23.02.23.
//

import Foundation

public final class PlayingTranslationsPlayMediaWithTranslationsUseCaseStateController: PlayMediaWithTranslationsUseCaseStateController {
    
    // MARK: - Properties
    
    private let translations: TranslationsToPlayData
    private let session: PlayMediaWithTranslationsUseCaseStateControllerActiveSession
    private weak var delegate: PlayMediaWithTranslationsUseCaseStateControllerDelegate?
    
    public var currentTime: TimeInterval {
        return session.playMediaUseCase.currentTime
    }
    
    public var duration: TimeInterval {
        return session.playMediaUseCase.duration
    }
    
    // MARK: - Initializers
    
    public init(
        translations: TranslationsToPlayData,
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
        
        return delegate.pause(
            // FIXME: 
            elapsedTime: 0,
            session: session
        )
    }
    
    public func prepare(session: PlayMediaWithTranslationsSession) async -> Result<Void, PlayMediaWithTranslationsUseCaseError> {
        
        guard let delegate = delegate else {
            return .failure(.internalError(nil))
        }
        
        return await delegate.load(session: session)
    }
    
    public func resume() -> Result<Void, PlayMediaWithTranslationsUseCaseError> {
        return .success(())
    }
    
    public func play(atTime: TimeInterval) -> Result<Void, PlayMediaWithTranslationsUseCaseError> {
        
        guard let delegate = delegate else {
            return .failure(.internalError(nil))
        }
        
        return delegate.play(atTime: atTime, session: session)
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
    
    public func set(currentTime: TimeInterval) {
        print("Implement")
    }
    
    public func run() async -> Result<Void, PlayMediaWithTranslationsUseCaseError> {
        
        do {
            
            for try await pronounciationState in pronounceCurrentTranslationItem(translations) {
                
                switch pronounciationState {
                    
                case .stopped, .paused:
                    return .success(())
                    
                case .finished, .loading:
                    continue
                    
                case .playing(let stateData):
                    continue
                }
            }
            
        } catch {
            return .failure(.internalError(nil))
        }
        
        delegate?.didPronounce(session: session)
        return .success(())
    }
}
