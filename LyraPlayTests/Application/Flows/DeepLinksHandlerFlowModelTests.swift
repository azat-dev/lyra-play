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
        applcationFlowModel: ApplicationFlowModelMock
    )

    // MARK: - Methods

    func createSUT() -> SUT {

        let applcationFlowModel = mock(ApplicationFlowModel.self)
        let router = mock(DeepLinksRouter.self)

        let flowModel = DeepLinksHandlerFlowModelImpl(
            applcationFlowModel: applcationFlowModel,
            router: router)

        detectMemoryLeak(instance: flowModel)

        return (
            flowModel: flowModel,
            applcationFlowModel: applcationFlowModel
        )
    }

    func test_handle() async throws {

        // Given
        let sut = createSUT()

        // When
//        let result = sut.flowModel.handle(url: url)

        // Then
//        let item = try AssertResultSucceded(result)
    }
}
