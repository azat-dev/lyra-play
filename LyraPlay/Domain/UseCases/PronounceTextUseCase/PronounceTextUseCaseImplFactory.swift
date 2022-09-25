//
//  PronounceTextUseCaseImplFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 13.09.2022.
//

import Foundation

public final class PronounceTextUseCaseImplFactory: PronounceTextUseCaseFactory {

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

    public func create() -> PronounceTextUseCase {

        let audioPlayer = audioPlayerFactory.create()
        let textToSpeechConverter = textToSpeechConverterFactory.create()
        
        return PronounceTextUseCaseImpl(
            textToSpeechConverter: textToSpeechConverter,
            audioPlayer: audioPlayer
        )
    }
}
