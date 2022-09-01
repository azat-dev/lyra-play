//
//  PronounceTranslationsUseCaseImplFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 01.09.2022.
//

import Foundation

public final class PronounceTranslationsUseCaseImplFactory: PronounceTranslationsUseCaseFactory {

    // MARK: - Properties

    private let textToSpeechConverter: TextToSpeechConverter
    private let audioPlayer: AudioPlayer

    // MARK: - Initializers

    public init(
        textToSpeechConverter: TextToSpeechConverter,
        audioPlayer: AudioPlayer
    ) {

        self.textToSpeechConverter = textToSpeechConverter
        self.audioPlayer = audioPlayer
    }

    // MARK: - Methods

    public func create() -> PronounceTranslationsUseCase {

        return PronounceTranslationsUseCaseImpl(
            textToSpeechConverter: textToSpeechConverter,
            audioPlayer: audioPlayer
        )
    }
}
