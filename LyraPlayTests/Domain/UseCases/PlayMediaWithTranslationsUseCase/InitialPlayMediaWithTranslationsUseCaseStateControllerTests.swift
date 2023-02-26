//
//  InitialPlayMediaWithTranslationsUseCaseStateControllerTests.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 21.02.2023.
//

import Foundation
import XCTest
import Mockingbird
import LyraPlay

class InitialPlayMediaWithTranslationsUseCaseStateControllerImplTests: XCTestCase {

    typealias SUT = (
        controller: InitialPlayMediaWithTranslationsUseCaseStateController,
        delegate: PlayMediaWithTranslationsUseCaseStateControllerDelegateMock
    )

    // MARK: - Methods

    func createSUT(session: PlayMediaWithTranslationsSession) -> SUT {

        let delegate = mock(PlayMediaWithTranslationsUseCaseStateControllerDelegate.self)

        let controller = InitialPlayMediaWithTranslationsUseCaseStateController(delegate: delegate)

        detectMemoryLeak(instance: controller)

        return (
            controller: controller,
            delegate: delegate
        )
    }
    
    // MARK: - Methods
    
    func test_prepare() async throws {
        
        // Given
        let session = PlayMediaWithTranslationsSession(
            mediaId: UUID(),
            learningLanguage: "English",
            nativeLanguage: "French"
        )
        
        let sut = createSUT(session: session)

        given(await sut.delegate.load(session: any()))
            .willReturn(.success(()))
        
        // When
        let result = await sut.controller.prepare(session: session)
        
        // Then
        try AssertResultSucceded(result)
        
        verify(await sut.delegate.load(session: session))
            .wasCalled(1)
    }
}
