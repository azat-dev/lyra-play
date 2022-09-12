//
//  EditDictionaryItemUseCaseImplTests.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 12.09.2022.
//

import Foundation
import XCTest
import Mockingbird
import LyraPlay

class EditDictionaryItemUseCaseImplTests: XCTestCase {

    typealias SUT = (
        useCase: EditDictionaryItemUseCase,
        dictionaryRepository: DictionaryRepositoryMock
    )

    // MARK: - Methods

    func createSUT() -> SUT {

        let dictionaryRepository = mock(DictionaryRepository.self)

        let useCase = EditDictionaryItemUseCaseImpl(dictionaryRepository: dictionaryRepository)

        detectMemoryLeak(instance: useCase)

        return (
            useCase: useCase,
            dictionaryRepository: dictionaryRepository
        )
    }

    func test_putItem() async throws {

        // Given
        let sut = createSUT()
        let dictionaryItem: DictionaryItem = .anyNewDictionaryItem(suffix: "test")

        // When
        let result = await sut.useCase.putItem(item: dictionaryItem)

        // Then
        let savedItem = try AssertResultSucceded(result)
        
        XCTAssertNotNil(savedItem.id)
        XCTAssertEqual(savedItem.originalText, dictionaryItem.originalText)
    }
}
