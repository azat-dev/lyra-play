//
//  LoadingPlayMediaWithTranslationsUseCaseStateControllerImplFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 21.02.2023.
//

import Foundation

public final class LoadingPlayMediaWithTranslationsUseCaseStateControllerImplFactory: LoadingPlayMediaWithTranslationsUseCaseStateControllerFactory {
    
    private let playMediaUseCaseFactory: PlayMediaWithSubtitlesUseCaseFactoryNew
    private let provideTranslationsToPlayUseCaseFactory: ProvideTranslationsToPlayUseCaseFactory
    private let pronounceTranslationsUseCaseFactory: PronounceTranslationsUseCaseFactory
    
    // MARK: - Initializers
    
    public init(
        playMediaUseCaseFactory: PlayMediaWithSubtitlesUseCaseFactoryNew,
        provideTranslationsToPlayUseCaseFactory: ProvideTranslationsToPlayUseCaseFactory,
        pronounceTranslationsUseCaseFactory: PronounceTranslationsUseCaseFactory
    ) {
        
        self.playMediaUseCaseFactory = playMediaUseCaseFactory
        self.provideTranslationsToPlayUseCaseFactory = provideTranslationsToPlayUseCaseFactory
        self.pronounceTranslationsUseCaseFactory = pronounceTranslationsUseCaseFactory
    }
    
    // MARK: - Methods
    
    public func make(
        session: PlayMediaWithTranslationsSession,
        delegate: PlayMediaWithTranslationsUseCaseStateControllerDelegate
    ) -> LoadingPlayMediaWithTranslationsUseCaseStateController {
        
        return LoadingPlayMediaWithTranslationsUseCaseStateControllerImpl(
            session: session,
            delegate: delegate,
            playMediaUseCaseFactory: playMediaUseCaseFactory,
            provideTranslationsToPlayUseCaseFactory: provideTranslationsToPlayUseCaseFactory,
            pronounceTranslationsUseCaseFactory: pronounceTranslationsUseCaseFactory
        )
    }
}
