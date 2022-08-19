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
        
        let useCase = DefaultBrowseDictionaryUseCase(
            dictionaryRepository: dictionaryRepository
        )
        detectMemoryLeak(instance: useCase)
        
        return (
            useCase,
            dictionaryRepository
        )
    }
    
    // MARK: - Test Methods
    
    func test_listItems__empty_dictionary() async throws {
        
        let sut = createSUT()

        // Given
        // Empty dictionary repository
        
        // When
        let result = await sut.useCase.listItems()
        
        // Then
        let items = try AssertResultSucceded(result)
        AssertEqualReadable(items, [])
    }
}
