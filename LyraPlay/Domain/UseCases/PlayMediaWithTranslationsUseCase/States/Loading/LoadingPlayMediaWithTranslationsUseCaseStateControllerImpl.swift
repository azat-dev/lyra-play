//
//  LoadingPlayMediaWithTranslationsUseCaseStateControllerImpl.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 21.02.2023.
//

import Foundation

public final class LoadingPlayMediaWithTranslationsUseCaseStateControllerImpl: LoadingPlayMediaWithTranslationsUseCaseStateController {
    
    // MARK: - Properties
    
    public let session: PlayMediaWithTranslationsSession
    public weak var delegate: PlayMediaWithTranslationsUseCaseStateControllerDelegate?
    
    public let playMediaUseCaseFactory: PlayMediaWithSubtitlesUseCaseFactoryNew
    public let provideTranslationsToPlayUseCaseFactory: ProvideTranslationsToPlayUseCaseFactory
    public let pronounceTranslationsUseCaseFactory: PronounceTranslationsUseCaseFactory
    
    // MARK: - Initializers
    
    public init(
        session: PlayMediaWithTranslationsSession,
        delegate: PlayMediaWithTranslationsUseCaseStateControllerDelegate,
        playMediaUseCaseFactory: PlayMediaWithSubtitlesUseCaseFactoryNew,
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
    
    public func play() -> Result<Void, PlayMediaWithTranslationsUseCaseError> {
        
        return .failure(.noActiveMedia)
    }
    
    public func play(atTime: TimeInterval) -> Result<Void, PlayMediaWithTranslationsUseCaseError> {
        
        return .failure(.noActiveMedia)
    }
    
    public func pause() -> Result<Void, PlayMediaWithTranslationsUseCaseError> {
        
        return .failure(.noActiveMedia)
    }
    
    public func stop() -> Result<Void, PlayMediaWithTranslationsUseCaseError> {
        
        return .success(())
    }
    
    public func togglePlay() -> Result<Void, PlayMediaWithTranslationsUseCaseError> {
        
        return .failure(.noActiveMedia)
    }
    
    public func load(session: PlayMediaWithTranslationsSession) async -> Result<Void, PlayMediaWithTranslationsUseCaseError> {
        fatalError()
    }
}
