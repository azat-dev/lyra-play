//
//  PlayMediaWithTranslationsUseCaseImpl.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 26.08.22.
//

import Foundation

public final class PlayMediaWithTranslationsUseCaseFactoryImpl: PlayMediaWithTranslationsUseCaseFactory {
    
    public init() {}
    
    public func create(
        playMediaWithSubtitlesUseCase: PlayMediaWithSubtitlesUseCase,
        playSubtitlesUseCaseFactory: PlaySubtitlesUseCaseFactory,
        provideTranslationsToPlayUseCase: ProvideTranslationsToPlayUseCase,
        pronounceTranslationsUseCase: PronounceTranslationsUseCase
    ) -> PlayMediaWithTranslationsUseCase {
        
        return PlayMediaWithTranslationsUseCaseImpl(
            playMediaWithSubtitlesUseCase: playMediaWithSubtitlesUseCase,
            playSubtitlesUseCaseFactory: playSubtitlesUseCaseFactory,
            provideTranslationsToPlayUseCase: provideTranslationsToPlayUseCase,
            pronounceTranslationsUseCase: pronounceTranslationsUseCase
        )
    }
}
