//
//  BrowseDictionaryUseCaseTests.swift
//  LyraPlayTests
//
//  Created by Azat Kaiumov on 19.08.2022.
//

import XCTest
import LyraPlay

class BrowseDictionaryUseCaseTests: XCTestCase {
    
    typealias SUT = (
        useCase: BrowseDictionaryUseCase,
        dictionaryRepository: DictionaryRepository
    )
    
    func createSUT() -> SUT {
        
        let storeURL = URL(fileURLWithPath: "/dev/null")
        let coreDataStore = try! CoreDataStore(storeURL: storeURL)
        
        let dictionaryRepository = CoreDataDictionaryRepository(coreDataStore: coreDataStore)
        
        let useCase = BrowseDictionaryUseCaseImpl(
            dictionaryRepository: dictionaryRepository
        )
        detectMemoryLeak(instance: useCase)
        
        return (
            useCase,
            dictionaryRepository
        )
    }
    
    // MARK: - Helpers
    
    func givenPopulatedRepository(_ sut: SUT) async throws -> [DictionaryItem] {
        
        var items = [DictionaryItem]()
        let numberOfItems = 10
        
        for _ in 0..<numberOfItems {
    
            let dictionaryItem: DictionaryItem = .anyNewDictionaryItem(suffix: UUID().uuidString)
            let putResult = await sut.dictionaryRepository.putItem(dictionaryItem)
            let savedItem = try AssertResultSucceded(putResult)
            
            items.append(savedItem)
        }
        
        return items
    }
    
    // MARK: - Test Methods
    
    func test_listItems__empty_dictionary() async throws {
        
        let sut = createSUT()

        // Given
        // Empty repository
        
        // When
        let result = await sut.useCase.listItems()
        
        // Then
        let items = try AssertResultSucceded(result)
        AssertEqualReadable(items, [])
    }
    
    func test_listItems__not_empty_dictionary() async throws {
        
        let sut = createSUT()

        // Given
        let dictionaryItems = try await givenPopulatedRepository(sut)
        
        // When
        let result = await sut.useCase.listItems()
        
        // Then
        let sortedDictionaryItems = dictionaryItems.sorted(by: { $0.originalText < $1.originalText })
        let receivedItems = try AssertResultSucceded(result)
        
        AssertEqualReadable(receivedItems.map { $0.id }, sortedDictionaryItems.map { $0.id })
    }
}
