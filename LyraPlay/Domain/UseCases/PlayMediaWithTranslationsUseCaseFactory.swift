//
//  PlayMediaWithTranslationsUseCaseFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 26.08.22.
//

import Foundation

public protocol PlayMediaWithTranslationsUseCaseFactory {
    
    func create(
        playMediaWithSubtitlesUseCase: PlayMediaWithSubtitlesUseCase,
        playSubtitlesUseCaseFactory: PlaySubtitlesUseCaseFactory,
        provideTranslationsToPlayUseCase: ProvideTranslationsToPlayUseCase,
        pronounceTranslationsUseCase: PronounceTranslationsUseCase
    ) -> PlayMediaWithTranslationsUseCase
}

