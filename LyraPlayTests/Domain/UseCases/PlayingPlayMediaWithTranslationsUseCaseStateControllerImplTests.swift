//
//  PlayingPlayMediaWithTranslationsUseCaseStateControllerImplTests.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 22.02.2023.
//

import Foundation
import XCTest
import Mockingbird
import LyraPlay

class PlayingPlayMediaWithTranslationsUseCaseStateControllerImplTests: XCTestCase {

    typealias SUT = (
        useCase: PlayingPlayMediaWithTranslationsUseCaseStateController,
        delegate: PlayMediaWithTranslationsUseCaseStateControllerDelegateMock
    )

    // MARK: - Methods

    func createSUT() -> SUT {

        let delegate = mock(PlayMediaWithTranslationsUseCaseStateControllerDelegate.self)

        let useCase = PlayingPlayMediaWithTranslationsUseCaseStateControllerImpl(delegate: delegate)

        detectMemoryLeak(instance: useCase)

        return (
            useCase: useCase,
            delegate: delegate
        )
    }
}