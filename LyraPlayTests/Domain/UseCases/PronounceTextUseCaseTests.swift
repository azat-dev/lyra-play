//
//  PronounceTextUseCaseImplTests.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 13.09.2022.
//

import Foundation
import XCTest
import Mockingbird
import LyraPlay

class PronounceTextUseCaseTests: XCTestCase {

    typealias SUT = (
        useCase: PronounceTextUseCase,
        textToSpeechConverter: TextToSpeechConverterMock,
        audioPlayer: AudioPlayerMock
    )

    // MARK: - Methods

    func createSUT() -> SUT {

        let textToSpeechConverter = TextToSpeechConverterMock()

        let audioPlayer = AudioPlayerMock()

        let useCase = PronounceTextUseCaseImpl(
            textToSpeechConverter: textToSpeechConverter,
            audioPlayer: audioPlayer
        )

        detectMemoryLeak(instance: useCase)

        return (
            useCase: useCase,
            textToSpeechConverter: textToSpeechConverter,
            audioPlayer: audioPlayer
        )
    }

    func test_pronounce() async throws {

        // Given
        let sut = createSUT()

        // When
        sut.useCase.pronounce(text: "Test", language: "en_US")

        // Then
    }
}
