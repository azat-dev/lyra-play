//
//  LoadedPlayMediaWithTranslationsUseCaseStateControllerImpl.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 22.02.2023.
//

import Foundation

public final class LoadedPlayMediaWithTranslationsUseCaseStateControllerImpl: LoadedPlayMediaWithTranslationsUseCaseStateController {

    // MARK: - Properties

    public let session: PlayMediaWithTranslationsUseCaseStateControllerActiveSession
    public weak var delegate: PlayMediaWithTranslationsUseCaseStateControllerDelegate? 

    // MARK: - Initializers

    public init(
        session: PlayMediaWithTranslationsUseCaseStateControllerActiveSession,
        delegate: PlayMediaWithTranslationsUseCaseStateControllerDelegate
    ) {

        self.session = session
        self.delegate = delegate
    }
    
    public func prepare(session: PlayMediaWithTranslationsSession) async -> Result<Void, PlayMediaWithTranslationsUseCaseError> {
        
        guard let delegate = delegate else {
            return .failure(.internalError(nil))
        }
        
        return await delegate.load(session: session)
    }
    
    public func play() -> Result<Void, PlayMediaWithTranslationsUseCaseError> {
        
        guard let delegate = delegate else {
            return .failure(.internalError(nil))
        }
        
        return delegate.play(
            session: session,
            delegate: delegate
        )
    }
    
    public func play(atTime: TimeInterval) -> Result<Void, PlayMediaWithTranslationsUseCaseError> {
        fatalError()
    }
    
    public func pause() -> Result<Void, PlayMediaWithTranslationsUseCaseError> {
        return .failure(.noActiveMedia)
    }
    
    public func stop() -> Result<Void, PlayMediaWithTranslationsUseCaseError> {
        return .failure(.noActiveMedia)
    }
    
    public func togglePlay() -> Result<Void, PlayMediaWithTranslationsUseCaseError> {
        
        return play()
    }
}