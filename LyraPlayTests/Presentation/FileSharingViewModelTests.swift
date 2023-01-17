//
//  FileSharingViewModelTests.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 17.01.2023.
//

import Foundation
import XCTest
import Mockingbird
import LyraPlay

class FileSharingViewModelTests: XCTestCase {

    typealias SUT = (
        viewModel: FileSharingViewModel,
        url: URLMock,
        delegate: FileSharingViewModelDelegateMock
    )

    // MARK: - Methods

    func createSUT() -> SUT {

        let url = mock(URL.self)

        let delegate = mock(FileSharingViewModelDelegate.self)

        let viewModel = FileSharingViewModelImpl(
            url: url,
            delegate: delegate
        )

        detectMemoryLeak(instance: viewModel)

        return (
            viewModel: viewModel,
            url: url,
            delegate: delegate
        )
    }

    func test_dispose() async throws {

        // Given
        let sut = createSUT()

        // When
        let result = sut.viewModel.dispose()

        // Then
        let item = try AssertResultSucceded(result)
    }
}