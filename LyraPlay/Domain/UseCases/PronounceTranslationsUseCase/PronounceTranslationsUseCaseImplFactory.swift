//
//  PronounceTranslationsUseCaseImplFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 01.09.2022.
//

import Foundation

public final class PronounceTranslationsUseCaseImplFactory: PronounceTranslationsUseCaseFactory {

    // MARK: - Properties

    private let textToSpeechConverterFactory: TextToSpeechConverterFactory
    private let audioPlayerFactory: AudioPlayerFactory

    // MARK: - Initializers

    public init(
        textToSpeechConverterFactory: TextToSpeechConverterFactory,
        audioPlayerFactory: AudioPlayerFactory
    ) {

        self.textToSpeechConverterFactory = textToSpeechConverterFactory
        self.audioPlayerFactory = audioPlayerFactory
    }

    // MARK: - Methods

    public func make() -> PronounceTranslationsUseCase {

        let audioPlayer = audioPlayerFactory.make()
        let textToSpeechConverter = textToSpeechConverterFactory.make()
        
        return PronounceTranslationsUseCaseImpl(
            textToSpeechConverter: textToSpeechConverter,
            audioPlayer: audioPlayer
        )
    }
}
