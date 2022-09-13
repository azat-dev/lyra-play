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

    func createSUT() -> SUT {

        let delegate = mock(AddDictionaryItemFlowModelDelegate.self)
        
        let editDictionaryItemViewModel = mock(EditDictionaryItemViewModel.self)
        let editDictionaryItemViewModelFactory = mock(EditDictionaryItemViewModelFactory.self)
        
        let editDelegate = mock(EditDictionaryItemViewModelDelegate.self)
        
        given(editDictionaryItemViewModelFactory.create(with: any(), delegate: editDelegate))
            .willReturn(editDictionaryItemViewModel)

        let flowModel = AddDictionaryItemFlowModelImpl(
            originalText: "",
            delegate: delegate,
            editDictionaryItemViewModelFactory: editDictionaryItemViewModelFactory
        )

        detectMemoryLeak(instance: flowModel)
        releaseMocks(
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
        let sut = createSUT()
        
        // When
        // init
        
        // Then
        XCTAssertNotNil(sut.flowModel.editDictionaryItemViewModel.value)
    }
}
