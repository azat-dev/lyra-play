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
        audioPlayer: AudioPlayerMockDeprecated
    )

    // MARK: - Methods

    func createSUT() -> SUT {

        let textToSpeechConverter = TextToSpeechConverterMock()

        let audioPlayer = AudioPlayerMockDeprecated()

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
        
        let statePromise = watch(sut.useCase.state)

        // When
        let _ = sut.useCase.pronounce(text: "Test", language: "en_US")

        // Then
        
        statePromise.expect([
            .loading,
            .loading,
            .finished
        ])
    }
}
