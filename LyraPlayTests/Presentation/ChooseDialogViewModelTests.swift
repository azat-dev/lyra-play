//
//  ChooseDialogViewModelTests.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 19.09.2022.
//

import Foundation
import XCTest
import Mockingbird
import LyraPlay

class ChooseDialogViewModelTests: XCTestCase {

    typealias SUT = (
        viewModel: ChooseDialogViewModel,
        delegate: ChooseDialogViewModelDelegateMock
    )

    // MARK: - Methods

    func createSUT(items: [ChooseDialogViewModelItem]) -> SUT {

        let delegate = mock(ChooseDialogViewModelDelegate.self)

        let viewModel = ChooseDialogViewModelImpl(
            items: items,
            delegate: delegate
        )

        detectMemoryLeak(instance: viewModel)

        return (
            viewModel: viewModel,
            delegate: delegate
        )
    }

    func test_choose() async throws {

        // Given
        let items: [ChooseDialogViewModelItem] = [
            .init(id: "1", title: "1"),
            .init(id: "2", title: "2"),
        ]
        
        let choosenItemId = items[0].id
        let sut = createSUT(items: items)
        
        given(sut.delegate.chooseDialogViewModelDidChoose(itemId: choosenItemId))
            .willReturn(())

        // When
        sut.viewModel.choose(itemId: choosenItemId)

        // Then
        verify(sut.delegate.chooseDialogViewModelDidChoose(itemId: choosenItemId))
            .wasCalled(1)
    }

    func test_cancel() async throws {

        // Given
        let items: [ChooseDialogViewModelItem] = [
            .init(id: "1", title: "1"),
        ]
        
        let sut = createSUT(items: items)
        
        given(sut.delegate.chooseDialogViewModelDidCancel())
            .willReturn(())

        // When
        sut.viewModel.cancel()

        // Then
        verify(sut.delegate.chooseDialogViewModelDidCancel())
            .wasCalled(1)
    }

    func test_dispose() async throws {
        // Given
        let items: [ChooseDialogViewModelItem] = [
            .init(id: "1", title: "1"),
        ]
        
        let sut = createSUT(items: items)
        
        given(sut.delegate.chooseDialogViewModelDidDispose())
            .willReturn(())

        // When
        sut.viewModel.dispose()

        // Then
        verify(sut.delegate.chooseDialogViewModelDidDispose())
            .wasCalled(1)
    }
}
