//
//  TextToSpeechConverterTests.swift
//  LyraPlayTests
//
//  Created by Azat Kaiumov on 08.08.2022.
//

import XCTest
import AVFoundation

import LyraPlay

 class TextToSpeechConverterTests: XCTestCase {

    typealias SUT = TextToSpeechConverter

    func createSUT() -> SUT {

        let useCase = DefaultTextToSpeechConverter()
        detectMemoryLeak(instance: useCase)

        return useCase
    }

    func test_convert() async throws {

        let sut = createSUT()

        let resultOfConvertation = await sut.convert(
            text: "I like apples",
            language: "en-US"
        )

        let data = try AssertResultSucceded(resultOfConvertation)
        XCTAssertNotNil(data)
        
        let player = try AVAudioPlayer(data: data)
        XCTAssertNotEqual(player.duration, 0)
    }
}
