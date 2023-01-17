//
//  DictionaryExporterTests.swift
//  LyraPlayTests
//
//  Created by Azat Kaiumov on 17.01.23.
//

import Foundation
import XCTest

import LyraPlay

class DictionaryExporterTests: XCTestCase {
    
    typealias SUT = (
        exporter: DictionaryExporter,
        dictionaryRepository: DictionaryRepositoryMock
    )
    
    func createSUT() -> SUT {
        
        let dictionaryRepository = mock(DictionaryRepository.self)
        
        let exporter = DictionaryExporterImpl()
        detectMemoryLeak(instance: exporter)
        
        return (
            exporter,
            dictionaryRepository
        )
    }
    
    func test_export__empty_dictionary() async throws {
        
        // Given
        let sut = createSUT()
        given(sut.dictionaryRepository.listItems())
        // When
        let result = await sut.exporter.export(repository: sut.dictionaryRepository)
        
        // Then
        let exportedItems = try AssertResultSucceded(result)
        XCTAssertEqual(exportedItems.count, 0)
    }
    
    func test_export__not_empty_dictionary() async throws {
        
        // Given
        let sut = createSUT()
        
        // When
        let result = await sut.exporter.export(repository: sut.dictionaryRepository)
        
        // Then
        let exportedItems = try AssertResultSucceded(result)
        XCTAssertEqual(exportedItems.count, 0)
    }
}
