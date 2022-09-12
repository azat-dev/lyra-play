//
//  EditDictionaryItemViewModelTests.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 12.09.2022.
//

import Foundation
import XCTest
import Mockingbird
import LyraPlay

class EditDictionaryItemViewModelTests: XCTestCase {
    
    typealias SUT = (
        viewModel: EditDictionaryItemViewModel,
        delegate: EditDictionaryItemViewModelDelegateMock,
        loadDictionaryItemUseCase: LoadDictionaryItemUseCaseMock,
        editDictionaryItemUseCase: EditDictionaryItemUseCaseMock
    )
    
    // MARK: - Methods
    
    func createSUT(params: EditDictionaryItemParams) -> SUT {
        
        let delegate = mock(EditDictionaryItemViewModelDelegate.self)
        
        let loadDictionaryItemUseCase = mock(LoadDictionaryItemUseCase.self)
        
        let editDictionaryItemUseCase = mock(EditDictionaryItemUseCase.self)
        
        let viewModel = EditDictionaryItemViewModelImpl(
            params: params,
            delegate: delegate,
            loadDictionaryItemUseCase: loadDictionaryItemUseCase,
            editDictionaryItemUseCase: editDictionaryItemUseCase
        )
        
        detectMemoryLeak(instance: viewModel)
        
        return (
            viewModel: viewModel,
            delegate: delegate,
            loadDictionaryItemUseCase: loadDictionaryItemUseCase,
            editDictionaryItemUseCase: editDictionaryItemUseCase
        )
    }
    
    func test__create_new() async throws {
        
        // Given
        
        // When
        let sut = createSUT(params: .newItem(originalText: "test"))
        
        // Then
        guard case .editing(let data) = sut.viewModel.state.value else {
            
            XCTFail("Wrong state")
            return
        }

        XCTAssertEqual(data.originalText, "")
    }
    
    func test__create_new_with_initial_text() async throws {
        
        // Given
        
        // When
        let sut = createSUT(params: .newItem(originalText: "test"))
        
        // Then
        guard case .editing(let data) = sut.viewModel.state.value else {
            
            XCTFail("Wrong state")
            return
        }

        XCTAssertEqual(data.originalText, "test")
    }

    
    func test__load_existing() async throws {
        
        // Given
        let existingDictionaryItem = DictionaryItem.anyExistingDictonaryItem()
        
        // When
        let sut = createSUT(params: .existingItem(itemId: existingDictionaryItem.id!))
        given(await sut.loadDictionaryItemUseCase.load(itemId: existingDictionaryItem.id!))
            .willReturn(.success(existingDictionaryItem))
        
        // Then
        guard case .editing(let data) = sut.viewModel.state.value else {
            
            XCTFail("Wrong state")
            return
        }

        XCTAssertEqual(data.originalText, existingDictionaryItem.originalText)
    }
}
