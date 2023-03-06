//
//  LoadedPlayMediaWithTranslationsUseCaseStateController.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 22.02.2023.
//

import Foundation

public class LoadedPlayMediaWithTranslationsUseCaseStateController: PlayMediaWithTranslationsUseCaseStateController {

    // MARK: - Properties

    public let session: PlayMediaWithTranslationsUseCaseStateControllerActiveSession
    public weak var delegate: PlayMediaWithTranslationsUseCaseStateControllerDelegate?
    
    public var currentTime: TimeInterval {
        return session.playMediaUseCase.currentTime
    }
    
    public var duration: TimeInterval {
        return session.playMediaUseCase.duration
    }

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
    
    public func resume() -> Result<Void, PlayMediaWithTranslationsUseCaseError> {
        
        guard let delegate = delegate else {
            return .failure(.internalError(nil))
        }
        
        return delegate.resumePlaying(session: session)
    }
    
    public func play(atTime: TimeInterval) -> Result<Void, PlayMediaWithTranslationsUseCaseError> {
        
        guard let delegate = delegate else {
            return .failure(.internalError(nil))
        }
        
        return delegate.play(atTime: atTime, session: session)
    }
    
    public func pause() -> Result<Void, PlayMediaWithTranslationsUseCaseError> {
        return .failure(.noActiveMedia)
    }
    
    public func setTime(_ time: TimeInterval) {
        
        session.playMediaUseCase.setTime(time)
    }
    
    public func stop() -> Result<Void, PlayMediaWithTranslationsUseCaseError> {
        
        guard let delegate = delegate else {
            return .failure(.internalError(nil))
        }
        
        return delegate.stop(activeSession: session)
    }
    
    public func togglePlay() -> Result<Void, PlayMediaWithTranslationsUseCaseError> {
        
        return play(atTime: 0)
    }
}
