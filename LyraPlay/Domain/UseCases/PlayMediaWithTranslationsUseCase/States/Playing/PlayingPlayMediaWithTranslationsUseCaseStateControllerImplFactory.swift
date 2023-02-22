//
//  PlayingPlayMediaWithTranslationsUseCaseStateControllerImplFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 22.02.2023.
//

import Foundation

public final class PlayingPlayMediaWithTranslationsUseCaseStateControllerImplFactory: PlayingPlayMediaWithTranslationsUseCaseStateControllerFactory {
    
    // MARK: - Initializers
    
    public init() {}
    
    // MARK: - Methods
    
    public func make(
        session: PlayMediaWithTranslationsUseCaseStateControllerActiveSession,
        delegate: PlayMediaWithTranslationsUseCaseStateControllerDelegate
    ) -> PlayingPlayMediaWithTranslationsUseCaseStateController {
        
        return PlayingPlayMediaWithTranslationsUseCaseStateControllerImpl(
            session: session,
            delegate: delegate
        )
    }
}
