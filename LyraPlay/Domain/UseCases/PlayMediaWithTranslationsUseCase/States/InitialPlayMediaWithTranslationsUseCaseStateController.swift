//
//  InitialPlayMediaWithTranslationsUseCaseStateController.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 21.02.2023.
//

import Foundation

public class InitialPlayMediaWithTranslationsUseCaseStateController: PlayMediaWithTranslationsUseCaseStateController {
    
    // MARK: - Properties
    
    public weak var delegate: PlayMediaWithTranslationsUseCaseStateControllerDelegate?
    
    public let currentTime: TimeInterval = 0
    
    public let duration: TimeInterval = 0
    
    // MARK: - Initializers
    
    public init(
        delegate: PlayMediaWithTranslationsUseCaseStateControllerDelegate
    ) {
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
    
    public func setTime(_ time: TimeInterval) {
    }
    
    public func run(activeSession: PlayMediaWithTranslationsUseCaseStateControllerActiveSession) -> Result<Void, PlayMediaWithTranslationsUseCaseError> {
        
        activeSession.pronounceTranslationsUseCase.stop()
        let _ = activeSession.playMediaUseCase.stop()
        
        return .success(())
    }
}
