//
//  PausedPlayMediaWithTranslationsUseCaseStateController.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 24.02.23.
//

import Foundation

public class PausedPlayMediaWithTranslationsUseCaseStateController: PlayMediaWithTranslationsUseCaseStateController {
    
    // MARK: - Properties
    
    public let elapsedTime: TimeInterval
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
        elapsedTime: TimeInterval,
        session: PlayMediaWithTranslationsUseCaseStateControllerActiveSession,
        delegate: PlayMediaWithTranslationsUseCaseStateControllerDelegate
    ) {
        
        self.elapsedTime = elapsedTime
        self.session = session
        self.delegate = delegate
    }
    
    // MARK: - Methods
    
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
        
        return .success(())
    }
    
    public func togglePlay() -> Result<Void, PlayMediaWithTranslationsUseCaseError> {
        return resume()
    }
    
    public func stop() -> Result<Void, PlayMediaWithTranslationsUseCaseError> {
        
        guard let delegate = delegate else {
            return .failure(.internalError(nil))
        }
        
        return delegate.stop(activeSession: session)
    }
    
    public func setTime(_ time: TimeInterval) {
        
        session.playMediaUseCase.setTime(time)
    }
    
    public func getPosition(for time: TimeInterval) -> SubtitlesTimeSlot? {
        
        return session.playMediaUseCase.getPosition(for: time)
    }
    
    public func run() -> Result<Void, PlayMediaWithTranslationsUseCaseError> {
        
        session.playMediaUseCase.delegate = nil
        
        let pause = session.playMediaUseCase.pause()
        
        guard case .success = pause else {
            return pause.mapResult()
        }
        
        delegate?.didPause(controller: self)
        return .success(())
    }
}
