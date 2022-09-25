//
//  LoadDictionaryItemUseCaseTests.swift
//  LyraPlayTests
//
//  Created by Azat Kaiumov on 11.09.22.
//

import Foundation

import XCTest
import Mockingbird
import LyraPlay

class LoadDictionaryItemUseCaseTests: XCTestCase {

    typealias SUT = (
        useCase: LoadDictionaryItemUseCase,
        dictionaryRepository: DictionaryRepositoryMock
    )
    
    func createSUT() -> SUT  {
        
        let dictionaryRepository = mock(DictionaryRepository.self)
        
        let useCase = LoadDictionaryItemUseCaseImpl(
            dictionaryRepository: dictionaryRepository
        )
        
        detectMemoryLeak(instance: useCase)
        
        return (
            useCase,
            dictionaryRepository
        )
    }
    
    func test_load__not_existing_item() async throws {
        
        let sut = createSUT()
        
        // Given
        let notExistingItemId = UUID()
        
        given(await sut.dictionaryRepository.getItem(id: notExistingItemId))
            .willReturn(.failure(.itemNotFound))
        
        // When
        let result = await sut.useCase.load(itemId: notExistingItemId)
        
        // Then
        let error = try! AssertResultFailed(result)
        
        guard case .itemNotFound = error else {
            
            XCTFail("Wrong error type \(error)")
            return
        }
    }
    
    private func anyExistingDictionaryItem() -> DictionaryItem {
        
        return DictionaryItem(
            id: UUID(),
            createdAt: nil,
            updatedAt: nil,
            originalText: "",
            lemma: "",
            language: "",
            translations: []
        )
    }
    
    func test_load__existing_item() async throws {
        
        let sut = createSUT()
        
        // Given
        let existingItem = anyExistingDictionaryItem()

        given(await sut.dictionaryRepository.getItem(id: existingItem.id!))
            .willReturn(.success(existingItem))
        
        // When
        let result = await sut.useCase.load(itemId: existingItem.id!)
        
        // Then
        let receivedItem = try! AssertResultSucceded(result)
        XCTAssertEqual(receivedItem.id, existingItem.id)
    }
}
