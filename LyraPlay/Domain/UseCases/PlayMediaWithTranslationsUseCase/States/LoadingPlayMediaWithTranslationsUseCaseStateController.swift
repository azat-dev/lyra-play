//
//  LoadingPlayMediaWithTranslationsUseCaseStateController.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 21.02.2023.
//

import Foundation

public final class LoadingPlayMediaWithTranslationsUseCaseStateController: PlayMediaWithTranslationsUseCaseStateController {
    
    // MARK: - Properties
    
    public let session: PlayMediaWithTranslationsSession
    public weak var delegate: PlayMediaWithTranslationsUseCaseStateControllerDelegate?
    
    public let playMediaUseCaseFactory: PlayMediaWithSubtitlesUseCaseFactory
    public let provideTranslationsToPlayUseCaseFactory: ProvideTranslationsToPlayUseCaseFactory
    public let pronounceTranslationsUseCaseFactory: PronounceTranslationsUseCaseFactory
    
    public let currentTime: TimeInterval = 0
    public let duration: TimeInterval = 0
    
    // MARK: - Initializers
    
    public init(
        session: PlayMediaWithTranslationsSession,
        delegate: PlayMediaWithTranslationsUseCaseStateControllerDelegate,
        playMediaUseCaseFactory: PlayMediaWithSubtitlesUseCaseFactory,
        provideTranslationsToPlayUseCaseFactory: ProvideTranslationsToPlayUseCaseFactory,
        pronounceTranslationsUseCaseFactory: PronounceTranslationsUseCaseFactory
    ) {
        
        self.session = session
        self.delegate = delegate
        self.playMediaUseCaseFactory = playMediaUseCaseFactory
        self.provideTranslationsToPlayUseCaseFactory = provideTranslationsToPlayUseCaseFactory
        self.pronounceTranslationsUseCaseFactory = pronounceTranslationsUseCaseFactory
    }
    
    // MARK: - Methods
    
    public func prepare(session: PlayMediaWithTranslationsSession) async -> Result<Void, PlayMediaWithTranslationsUseCaseError> {
        
        guard let delegate = delegate else {
            return .failure(.internalError(nil))
        }
        
        return await delegate.load(session: session)
    }
    
    public func resume() -> Result<Void, PlayMediaWithTranslationsUseCaseError> {
        
        return .failure(.noActiveMedia)
    }
    
    public func play(atTime: TimeInterval) -> Result<Void, PlayMediaWithTranslationsUseCaseError> {
        
        return .failure(.noActiveMedia)
    }
    
    public func pause() -> Result<Void, PlayMediaWithTranslationsUseCaseError> {
        
        return .failure(.noActiveMedia)
    }
    
    public func stop() -> Result<Void, PlayMediaWithTranslationsUseCaseError> {
        
        guard let delegate = delegate else {
            return .failure(.internalError(nil))
        }
        
        return delegate.stop(session: session)
    }
    
    public func togglePlay() -> Result<Void, PlayMediaWithTranslationsUseCaseError> {
        
        return .failure(.noActiveMedia)
    }
    
    public func setTime(_ time: TimeInterval) {
    }
    
    public func getPosition(for time: TimeInterval) -> SubtitlesTimeSlot? {
        
        return nil
    }
    
    public func load() async -> Result<Void, PlayMediaWithTranslationsUseCaseError> {
        
        let playMediaWithSubtitlesUseCase = playMediaUseCaseFactory.make()
        
        let result = await playMediaWithSubtitlesUseCase.prepare(
            params: .init(mediaId: session.mediaId, subtitlesLanguage: session.learningLanguage)
        )
        
        guard case .success = result else {
            delegate?.didFailLoad(session: session)
            return result.mapResult()
        }
        
        guard
            case .activeSession(_, let playerState) = playMediaWithSubtitlesUseCase.state.value,
            case .loaded = playerState.value
        else {
            delegate?.didFailLoad(session: session)
            return .failure(.internalError(nil))
        }
        
        let provideTranslationsToPlayUseCase = provideTranslationsToPlayUseCaseFactory.make()
        
        if let subtitles = playMediaWithSubtitlesUseCase.subtitlesState.value?.subtitles {
            
            await provideTranslationsToPlayUseCase.prepare(
                params: .init(
                    mediaId: session.mediaId,
                    nativeLanguage: session.nativeLanguage,
                    learningLanguage: session.learningLanguage,
                    subtitles: subtitles
                )
            )
        }
        
        let pronounceTranslationsUseCase = pronounceTranslationsUseCaseFactory.make()
        
        delegate?.didLoad(
            session: .init(
                session: session,
                playMediaUseCase: playMediaWithSubtitlesUseCase,
                provideTranslationsToPlayUseCase: provideTranslationsToPlayUseCase,
                pronounceTranslationsUseCase: pronounceTranslationsUseCase
            )
        )

        return .success(())
    }
}
