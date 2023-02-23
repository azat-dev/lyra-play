//
//  InitialPlayMediaWithSubtitlesUseCaseControllerTests.swift
//  LyraPlayTests
//
//  Created by Azat Kaiumov on 19.02.23.
//

import Foundation
import XCTest
import Mockingbird

import LyraPlay

class InitialPlayMediaWithSubtitlesUseCaseControllerTests: XCTestCase {
    
    typealias SUT = (
        controller: InitialPlayMediaWithSubtitlesUseStateController,
        delegate: PlayMediaWithSubtitlesUseStateControllerDelegateMock
    )
    
    func createSUT() -> SUT {
        
        let delegate = mock(PlayMediaWithSubtitlesUseStateControllerDelegate.self)
        let controller = InitialPlayMediaWithSubtitlesUseStateController(delegate: delegate)
        
        detectMemoryLeak(instance: controller)
        
        return (
            controller,
            delegate
        )
    }
    
    // MARK: - Test Methods
    
    func test_preparing() async throws {
        
        let sut = createSUT()

        // Given
        let mediaId = UUID()
        
        let params = PlayMediaWithSubtitlesSessionParams(
            mediaId: mediaId,
            subtitlesLanguage: "English"
        )
        
        given(await sut.delegate.load(params: any()))
            .willReturn(.success(()))
        
        // When
        let result = await sut.controller.prepare(params: params)
        
        // Then
        try AssertResultSucceded(result)
        
        verify(await sut.delegate.load(params: params))
            .wasCalled(1)
    }
}
