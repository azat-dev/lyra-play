//
//  AddDictionaryItemFlowModelTests.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 12.09.2022.
//

import Foundation
import XCTest
import Mockingbird
import LyraPlay

class AddDictionaryItemFlowModelTests: XCTestCase {

    typealias SUT = (
        flowModel: AddDictionaryItemFlowModel,
        delegate: AddDictionaryItemFlowModelDelegateMock,
        editDictionaryItemViewModelFactory: EditDictionaryItemViewModelFactoryMock
    )

    // MARK: - Methods

    func createSUT(originalText: String?) -> SUT {

        let delegate = mock(AddDictionaryItemFlowModelDelegate.self)
        
        let editDictionaryItemViewModel = mock(EditDictionaryItemViewModel.self)
        let editDictionaryItemViewModelFactory = mock(EditDictionaryItemViewModelFactory.self)
        
        given(editDictionaryItemViewModelFactory.make(with: any(), delegate: any()))
            .willReturn(editDictionaryItemViewModel)

        let flowModel = AddDictionaryItemFlowModelImpl(
            originalText: originalText,
            delegate: delegate,
            editDictionaryItemViewModelFactory: editDictionaryItemViewModelFactory
        )

        detectMemoryLeak(instance: flowModel)
        releaseMocks(
            delegate,
            editDictionaryItemViewModelFactory,
            editDictionaryItemViewModel
        )

        return (
            flowModel: flowModel,
            delegate: delegate,
            editDictionaryItemViewModelFactory: editDictionaryItemViewModelFactory
        )
    }
    
    func test_loading() {
        
        // Given
        let originalText = "Some text"
        let sut = createSUT(originalText: originalText)
        
        // When
        // Initialization
        
        // Then
        XCTAssertNotNil(sut.flowModel.editDictionaryItemViewModel.value)
        verify(
            sut.editDictionaryItemViewModelFactory.make(
                with: .newItem(originalText: originalText),
                delegate: any()
            )
        ).wasCalled(1)
    }
}
