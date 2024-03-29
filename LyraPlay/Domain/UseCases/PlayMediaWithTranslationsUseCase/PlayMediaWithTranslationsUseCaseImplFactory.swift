//
//  PlayMediaWithTranslationsUseCaseImplFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 31.08.2022.
//

import Foundation

public final class PlayMediaWithTranslationsUseCaseImplFactory: PlayMediaWithTranslationsUseCaseFactory {

    // MARK: - Properties

    private let audioSessionFactory: AudioSessionFactory
    private let playMediaWithSubtitlesUseCaseFactory: PlayMediaWithSubtitlesUseCaseFactory
    private let provideTranslationsToPlayUseCaseFactory: ProvideTranslationsToPlayUseCaseFactory
    private let pronounceTranslationsUseCaseFactory: PronounceTranslationsUseCaseFactory

    // MARK: - Initializers

    public init(
        audioSessionFactory: AudioSessionFactory,
        playMediaWithSubtitlesUseCaseFactory: PlayMediaWithSubtitlesUseCaseFactory,
        provideTranslationsToPlayUseCaseFactory: ProvideTranslationsToPlayUseCaseFactory,
        pronounceTranslationsUseCaseFactory: PronounceTranslationsUseCaseFactory
    ) {

        self.audioSessionFactory = audioSessionFactory
        self.playMediaWithSubtitlesUseCaseFactory = playMediaWithSubtitlesUseCaseFactory
        self.provideTranslationsToPlayUseCaseFactory = provideTranslationsToPlayUseCaseFactory
        self.pronounceTranslationsUseCaseFactory = pronounceTranslationsUseCaseFactory
    }

    // MARK: - Methods

    public func make() -> PlayMediaWithTranslationsUseCase {

        let audioSession = audioSessionFactory.make()
        let provideTranslationsToPlayUseCase = provideTranslationsToPlayUseCaseFactory.make()
        
        return PlayMediaWithTranslationsUseCaseImpl(
            audioSession: audioSession,
            playMediaUseCaseFactory: playMediaWithSubtitlesUseCaseFactory,
            provideTranslationsToPlayUseCaseFactory: provideTranslationsToPlayUseCaseFactory,
            pronounceTranslationsUseCaseFactory: pronounceTranslationsUseCaseFactory
        )
    }

}
