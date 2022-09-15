//
//  ConfirmDialogViewModelTests.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 15.09.2022.
//

import Foundation
import XCTest
import Mockingbird
import LyraPlay

class ConfirmDialogViewModelTests: XCTestCase {

    typealias SUT = (
        viewModel: ConfirmDialogViewModel,
        delegate: ConfirmDialogViewModelDelegateMock
    )

    // MARK: - Methods

    func createSUT() -> SUT {

        let delegate = mock(ConfirmDialogViewModelDelegate.self)

        let viewModel = ConfirmDialogViewModelImpl(
            messageText: "",
            confirmText: "",
            cancelText: "",
            isDestructive: false,
            delegate: delegate
        )

        detectMemoryLeak(instance: viewModel)

        return (
            viewModel: viewModel,
            delegate: delegate
        )
    }

    func test_confirm() async throws {

        // Given
        let sut = createSUT()

        // When
        sut.viewModel.confirm()

        // Then
        verify(sut.delegate.confirmDialogDidConfirm())
            .wasCalled(1)
    }

    func test_cancel() async throws {

        // Given
        let sut = createSUT()

        // When
        sut.viewModel.cancel()

        // Then
        verify(sut.delegate.confirmDialogDidCancel())
            .wasCalled(1)
    }
    
    func test_dispose() async throws {

        // Given
        let sut = createSUT()

        // When
        sut.viewModel.dispose()

        // Then
        verify(sut.delegate.confirmDialogDispose())
            .wasCalled(1)
    }
}
