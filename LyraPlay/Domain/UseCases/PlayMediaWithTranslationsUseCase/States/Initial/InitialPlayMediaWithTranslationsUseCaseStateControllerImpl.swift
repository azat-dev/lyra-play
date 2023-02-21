//
//  InitialPlayMediaWithTranslationsUseCaseStateControllerImpl.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 21.02.2023.
//

import Foundation

public final class InitialPlayMediaWithTranslationsUseCaseStateControllerImpl: InitialPlayMediaWithTranslationsUseCaseStateController {

    // MARK: - Properties

    private let session: PlayMediaWithTranslationsSession
    private weak var delegate: PlayMediaWithTranslationsUseCaseStateControllerDelegate? 

    // MARK: - Initializers

    public init(
        session: PlayMediaWithTranslationsSession,
        delegate: PlayMediaWithTranslationsUseCaseStateControllerDelegate
    ) {

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
}
