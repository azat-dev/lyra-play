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
        dictionaryRepository: DictionaryRepositoryMock,
        lemmatizer: LemmatizerMock
    )

    // MARK: - Methods

    func createSUT() -> SUT {

        let dictionaryRepository = mock(DictionaryRepository.self)

        let lemmatizer = mock(Lemmatizer.self)

        let useCase = EditDictionaryItemUseCaseImpl(
            dictionaryRepository: dictionaryRepository,
            lemmatizer: lemmatizer
        )

        detectMemoryLeak(instance: useCase)
        
        

        return (
            useCase: useCase,
            dictionaryRepository: dictionaryRepository,
            lemmatizer: lemmatizer
        )
    }
    
    func test_putItem() async throws {
        
        // Given
        let sut = createSUT()
        let dictionaryItem: DictionaryItem = .anyNewDictionaryItem(suffix: "test")
        
        given(await sut.dictionaryRepository.putItem(any()))
            .will { item in
                
                var itemCopy = item
                itemCopy.id = UUID()
                return .success(itemCopy)
            }

        given(sut.lemmatizer.lemmatize(text: any()))
            .willReturn([.init(lemma: "test", range: "a".range(of: "a")!)])
        
        // When
        let result = await sut.useCase.putItem(item: dictionaryItem)
        
        // Then
        let savedItem = try AssertResultSucceded(result)
        
        XCTAssertNotNil(savedItem.id)
        XCTAssertEqual(savedItem.originalText, dictionaryItem.originalText)
        XCTAssertEqual(savedItem.lemma, "test")
    }
}
