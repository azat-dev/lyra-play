//
//  PromptDialogViewModelTests.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 19.09.2022.
//

import Foundation
import XCTest
import Mockingbird
import LyraPlay

class PromptDialogViewModelTests: XCTestCase {

    typealias SUT = (
        viewModel: PromptDialogViewModel,
        delegate: PromptDialogViewModelDelegateMock
    )

    // MARK: - Methods

    func createSUT() -> SUT {

        let delegate = mock(PromptDialogViewModelDelegate.self)

        let viewModel = PromptDialogViewModelImpl(
            messageText: "",
            submitText: "",
            cancelText: "",
            delegate: delegate
        )

        detectMemoryLeak(instance: viewModel)

        return (
            viewModel: viewModel,
            delegate: delegate
        )
    }

    func test_cancel() async throws {

        // Given
        let sut = createSUT()
        given(sut.delegate.promptDialogViewModelDidCancel())
            .willReturn(())

        // When
        sut.viewModel.cancel()

        // Then
        verify(sut.delegate.promptDialogViewModelDidCancel())
            .wasCalled(1)
    }

    func test_dispose() async throws {

        // Given
        let sut = createSUT()
        given(sut.delegate.promptDialogViewModelDidDispose())
            .willReturn(())

        // When
        sut.viewModel.dispose()

        // Then
        verify(sut.delegate.promptDialogViewModelDidDispose())
            .wasCalled(1)
    }
    
    func test_submit() async throws {

        // Given
        let sut = createSUT()
        given(sut.delegate.promptDialogViewModelDidSubmit(value: any()))
            .willReturn(())
        
        let inputText = "test"
        let processingPromise = watch(sut.viewModel.isProcessing)

        // When
        sut.viewModel.submit(value: inputText)

        // Then
        verify(sut.delegate.promptDialogViewModelDidSubmit(value: inputText))
            .wasCalled(1)
        
        processingPromise.expect([
            false,
            true
        ])
    }
    
    func test_setErrorText() async throws {

        // Given
        let sut = createSUT()
        
        let errorTextPromise = watch(sut.viewModel.errorText)

        // When
        let errorText = "test"
        sut.viewModel.setErrorText(errorText)

        // Then
        errorTextPromise.expect([
            nil,
            errorText
        ])
    }
    
    func test_setProcessing() async throws {

        // Given
        let sut = createSUT()
        
        let processingPromise = watch(sut.viewModel.isProcessing)

        // When
        sut.viewModel.setIsProcessing(true)
        sut.viewModel.setIsProcessing(false)

        // Then
        processingPromise.expect([
            false,
            true,
            false
        ])
    }
}
