//
//  DeepLinksHandlerFlowModelTests.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 28.01.2023.
//

import Foundation
import XCTest
import Mockingbird
import LyraPlay

class DeepLinksHandlerFlowModelTests: XCTestCase {

    typealias SUT = (
        flowModel: DeepLinksHandlerFlowModel,
        mainFlowModel: MainFlowModelMock
    )

    // MARK: - Methods

    func createSUT() -> SUT {

        let mainFlowModel = mock(MainFlowModel.self)

        let flowModel = DeepLinksHandlerFlowModelImpl(mainFlowModel: mainFlowModel)

        detectMemoryLeak(instance: flowModel)

        return (
            flowModel: flowModel,
            mainFlowModel: mainFlowModel
        )
    }

    func test_handle() async throws {

        // Given
        let sut = createSUT()

        // When
        let result = sut.flowModel.handle()

        // Then
        let item = try AssertResultSucceded(result)
    }
}