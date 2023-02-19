//
//  AudioSessionTests.swift
//  LyraPlayTests
//
//  Created by Azat Kaiumov on 17.08.2022.
//

import XCTest
import AVFoundation

import LyraPlay

 class AudioSessionTests: XCTestCase {

    typealias SUT = AudioSession

    func createSUT() -> SUT {

        let useCase = AudioSessionImpl(mode: .mainAudio)
        detectMemoryLeak(instance: useCase)

        return useCase
    }

    func test_activate() async throws {

        let sut = createSUT()
        
        let result = sut.activate()
        try AssertResultSucceded(result)
    }

    func test_deactivate() async throws {

        let sut = createSUT()
        
        sut.activate()
        let result = sut.deactivate()
        try AssertResultSucceded(result)
    }
}
