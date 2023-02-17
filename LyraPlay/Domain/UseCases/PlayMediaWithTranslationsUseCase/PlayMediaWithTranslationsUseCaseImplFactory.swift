//
//  PlayMediaWithTranslationsUseCaseImplFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 31.08.2022.
//

import Foundation

public final class PlayMediaWithTranslationsUseCaseImplFactory: PlayMediaWithTranslationsUseCaseFactory {

    // MARK: - Properties

    private let playMediaWithSubtitlesUseCaseFactory: PlayMediaWithSubtitlesUseCaseFactory
    private let playSubtitlesUseCaseFactory: PlaySubtitlesUseCaseFactory
    private let provideTranslationsToPlayUseCaseFactory: ProvideTranslationsToPlayUseCaseFactory
    private let pronounceTranslationsUseCase: PronounceTranslationsUseCase

    // MARK: - Initializers

    public init(
        playMediaWithSubtitlesUseCaseFactory: PlayMediaWithSubtitlesUseCaseFactory,
        playSubtitlesUseCaseFactory: PlaySubtitlesUseCaseFactory,
        provideTranslationsToPlayUseCaseFactory: ProvideTranslationsToPlayUseCaseFactory,
        pronounceTranslationsUseCase: PronounceTranslationsUseCase
    ) {

        self.playMediaWithSubtitlesUseCaseFactory = playMediaWithSubtitlesUseCaseFactory
        self.playSubtitlesUseCaseFactory = playSubtitlesUseCaseFactory
        self.provideTranslationsToPlayUseCaseFactory = provideTranslationsToPlayUseCaseFactory
        self.pronounceTranslationsUseCase = pronounceTranslationsUseCase
    }

    // MARK: - Methods

    public func make() -> PlayMediaWithTranslationsUseCase {

        let playMediaWithSubtitlesUseCase = playMediaWithSubtitlesUseCaseFactory.make()
        let provideTranslationsToPlayUseCase = provideTranslationsToPlayUseCaseFactory.make()
        
        return PlayMediaWithTranslationsUseCaseImpl(
            playMediaWithSubtitlesUseCase: playMediaWithSubtitlesUseCase,
            playSubtitlesUseCaseFactory: playSubtitlesUseCaseFactory,
            provideTranslationsToPlayUseCase: provideTranslationsToPlayUseCase,
            pronounceTranslationsUseCase: pronounceTranslationsUseCase
        )
    }

}
