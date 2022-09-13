//
//  PronounceTextUseCaseImplFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 13.09.2022.
//

import Foundation

public final class PronounceTextUseCaseImplFactory: PronounceTextUseCaseFactory {

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

    public func create() -> PronounceTextUseCase {

        return PronounceTextUseCaseImpl(
            textToSpeechConverter: textToSpeechConverter,
            audioPlayer: audioPlayer
        )
    }
}