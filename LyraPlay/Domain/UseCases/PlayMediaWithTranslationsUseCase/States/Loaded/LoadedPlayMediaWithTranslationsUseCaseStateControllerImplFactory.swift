//
//  LoadedPlayMediaWithTranslationsUseCaseStateControllerImplFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 22.02.2023.
//

import Foundation

public final class LoadedPlayMediaWithTranslationsUseCaseStateControllerImplFactory: LoadedPlayMediaWithTranslationsUseCaseStateControllerFactory {
    
    // MARK: - Initializers
    
    public init() {}
    
    // MARK: - Methods
    
    public func make(
        session: PlayMediaWithTranslationsUseCaseStateControllerActiveSession,
        delegate: PlayMediaWithTranslationsUseCaseStateControllerDelegate
    ) -> LoadedPlayMediaWithTranslationsUseCaseStateController {
        
        return LoadedPlayMediaWithTranslationsUseCaseStateControllerImpl(
            session: session,
            delegate: delegate
        )
    }
}
