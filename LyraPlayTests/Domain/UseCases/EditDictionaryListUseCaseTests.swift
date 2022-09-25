//
//  EditDictionaryListUseCaseImplTests.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 13.09.2022.
//

import Foundation
import XCTest
import Mockingbird
import LyraPlay

class EditDictionaryListUseCaseImplTests: XCTestCase {

    typealias SUT = (
        useCase: EditDictionaryListUseCase,
        dictionaryRepository: DictionaryRepositoryMock
    )

    // MARK: - Methods

    func createSUT() -> SUT {

        let dictionaryRepository = mock(DictionaryRepository.self)

        let useCase = EditDictionaryListUseCaseImpl(dictionaryRepository: dictionaryRepository)

        detectMemoryLeak(instance: useCase)

        return (
            useCase: useCase,
            dictionaryRepository: dictionaryRepository
        )
    }
    
    func test_deleteItem__not_existing() async throws {

        let sut = createSUT()

        // Given
        let notExistingItemId = UUID()
        
        given(await sut.dictionaryRepository.deleteItem(id: notExistingItemId))
            .willReturn(.failure(.itemNotFound))

        // When
        let result = await sut.useCase.deleteItem(itemId: notExistingItemId)

        // Then
        let error = try AssertResultFailed(result)
        
        guard case .itemNotFound = error else {
            
            XCTFail("Wrong error type: \(error)")
            return
        }
    }

    func test_deleteItem() async throws {

        let sut = createSUT()

        // Given
        let existingItem = DictionaryItem.anyExistingDictonaryItem()
        
        given(await sut.dictionaryRepository.deleteItem(id: existingItem.id!))
            .willReturn(.success(()))

        // When
        let result = await sut.useCase.deleteItem(itemId: existingItem.id!)

        // Then
        try AssertResultSucceded(result)
    }
}
