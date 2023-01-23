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
    private let audioPlayer: AudioPlayer

    // MARK: - Initializers

    public init(
        textToSpeechConverterFactory: TextToSpeechConverterFactory,
        audioPlayer: AudioPlayer
    ) {

        self.textToSpeechConverterFactory = textToSpeechConverterFactory
        self.audioPlayer = audioPlayer
    }

    // MARK: - Methods

    public func create() -> PronounceTranslationsUseCase {

        let textToSpeechConverter = textToSpeechConverterFactory.create()
        
        return PronounceTranslationsUseCaseImpl(
            textToSpeechConverter: textToSpeechConverter,
            audioPlayer: audioPlayer
        )
    }
}
