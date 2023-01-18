//
//  FileSharingViewModelTests.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 18.01.2023.
//

import Foundation
import XCTest
import Mockingbird
import LyraPlay

class FileSharingViewModelTests: XCTestCase {

    typealias SUT = (
        viewModel: FileSharingViewModel,
        provideFileUrlUseCase: ProvideFileUrlUseCaseMock,
        delegate: FileSharingViewModelDelegateMock
    )

    // MARK: - Methods

    func createSUT() -> SUT {

        let provideFileUrlUseCase = mock(ProvideFileUrlUseCase.self)

        let delegate = mock(FileSharingViewModelDelegate.self)

        let viewModel = FileSharingViewModelImpl(
            provideFileUrlUseCase: provideFileUrlUseCase,
            delegate: delegate
        )

        detectMemoryLeak(instance: viewModel)

        return (
            viewModel: viewModel,
            provideFileUrlUseCase: provideFileUrlUseCase,
            delegate: delegate
        )
    }

    func test_dispose() async throws {

        // Given
        let sut = createSUT()

        // When
        sut.viewModel.dispose()

        // Then
        verify(sut.delegate.fileSharingViewModelDidDispose()).wasCalled()
    }
}
