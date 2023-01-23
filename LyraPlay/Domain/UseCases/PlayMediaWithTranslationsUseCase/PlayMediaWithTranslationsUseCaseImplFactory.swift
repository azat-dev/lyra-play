//
//  PlayMediaWithTranslationsUseCaseImplFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 31.08.2022.
//

import Foundation

public final class PlayMediaWithTranslationsUseCaseImplFactory: PlayMediaWithTranslationsUseCaseFactory {

    // MARK: - Properties

    private let playMediaWithSubtitlesUseCase: PlayMediaWithSubtitlesUseCase
    private let playSubtitlesUseCaseFactory: PlaySubtitlesUseCaseFactory
    private let provideTranslationsToPlayUseCaseFactory: ProvideTranslationsToPlayUseCaseFactory
    private let pronounceTranslationsUseCase: PronounceTranslationsUseCase

    // MARK: - Initializers

    public init(
        playMediaWithSubtitlesUseCase: PlayMediaWithSubtitlesUseCase,
        playSubtitlesUseCaseFactory: PlaySubtitlesUseCaseFactory,
        provideTranslationsToPlayUseCaseFactory: ProvideTranslationsToPlayUseCaseFactory,
        pronounceTranslationsUseCase: PronounceTranslationsUseCase
    ) {

        self.playMediaWithSubtitlesUseCase = playMediaWithSubtitlesUseCase
        self.playSubtitlesUseCaseFactory = playSubtitlesUseCaseFactory
        self.provideTranslationsToPlayUseCaseFactory = provideTranslationsToPlayUseCaseFactory
        self.pronounceTranslationsUseCase = pronounceTranslationsUseCase
    }

    // MARK: - Methods

    public func create() -> PlayMediaWithTranslationsUseCase {

        let provideTranslationsToPlayUseCase = provideTranslationsToPlayUseCaseFactory.create()
        
        return PlayMediaWithTranslationsUseCaseImpl(
            playMediaWithSubtitlesUseCase: playMediaWithSubtitlesUseCase,
            playSubtitlesUseCaseFactory: playSubtitlesUseCaseFactory,
            provideTranslationsToPlayUseCase: provideTranslationsToPlayUseCase,
            pronounceTranslationsUseCase: pronounceTranslationsUseCase
        )
    }

}
