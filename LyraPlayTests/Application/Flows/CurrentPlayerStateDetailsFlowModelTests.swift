//
//  CurrentPlayerStateDetailsFlowModelTests.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 30.09.2022.
//

import Foundation
import XCTest
import Mockingbird
import LyraPlay

class CurrentPlayerStateDetailsFlowModelTests: XCTestCase {

    typealias SUT = (
        flowModel: CurrentPlayerStateDetailsFlowModel,
        delegate: CurrentPlayerStateDetailsFlowModelDelegateMock,
        currentPlayerStateDetailsViewModelFactory: CurrentPlayerStateDetailsViewModelFactoryMock
    )

    // MARK: - Methods

    func createSUT() -> SUT {

        let delegate = mock(CurrentPlayerStateDetailsFlowModelDelegate.self)

        let currentPlayerStateDetailsViewModelFactory = mock(CurrentPlayerStateDetailsViewModelFactory.self)

        let flowModel = CurrentPlayerStateDetailsFlowModelImpl(
            delegate: delegate,
            currentPlayerStateDetailsViewModelFactory: currentPlayerStateDetailsViewModelFactory
        )

        detectMemoryLeak(instance: flowModel)

        return (
            flowModel: flowModel,
            delegate: delegate,
            currentPlayerStateDetailsViewModelFactory: currentPlayerStateDetailsViewModelFactory
        )
    }
    
    func test_loading() async throws {
        
        let sut = createSUT()
        
        // Given
        
        
        // When
        
        // Then
    }
}
