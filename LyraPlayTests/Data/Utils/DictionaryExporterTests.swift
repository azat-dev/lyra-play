//
//  DictionaryExporterTests.swift
//  LyraPlayTests
//
//  Created by Azat Kaiumov on 17.01.23.
//

import Foundation
import XCTest
import Mockingbird

import LyraPlay

class DictionaryExporterTests: XCTestCase {
    
    typealias SUT = (
        exporter: DictionaryExporter,
        dictionaryRepository: DictionaryRepositoryOutputListMock
    )
    
    func createSUT() -> SUT {
        
        let dictionaryRepository = mock(DictionaryRepositoryOutputList.self)
        
        let exporter = DictionaryExporterImpl()
        detectMemoryLeak(instance: exporter)
        
        return (
            exporter,
            dictionaryRepository
        )
    }
    
    func test_export__empty_dictionary() async throws {
        
        let sut = createSUT()
        
        // Given
        given(await sut.dictionaryRepository.listItems())
            .willReturn(.success([]))
        
        // When
        let result = await sut.exporter.export(repository: sut.dictionaryRepository)
        
        // Then
        let exportedItems = try AssertResultSucceded(result)
        XCTAssertEqual(exportedItems.count, 0)
    }
    
    func test_export__not_empty_dictionary() async throws {
        
        let sut = createSUT()
        
        // Given
        let items: [DictionaryItem] = [
            .init(
                originalText: "original1",
                lemma: "lemma1",
                language: "English",
                translations: [
                    .init(id: UUID(), text: "translation11"),
                    .init(id: UUID(), text: "translation12"),
                ]
            ),
            .init(
                originalText: "original2",
                lemma: "lemma2",
                language: "English",
                translations: [
                    .init(id: UUID(), text: "translation21"),
                ]
            )
        ]
        
        given(await sut.dictionaryRepository.listItems())
            .willReturn(.success(items))
        
        // When
        let result = await sut.exporter.export(repository: sut.dictionaryRepository)
        
        // Then
        let exportedItems = try AssertResultSucceded(result)
        
        let expectedItems: [ExportedDictionaryItem] = [
            .init(
                original: items[0].originalText,
                translations: [
                    items[0].translations[0].text,
                    items[0].translations[1].text
                ]
            )
        ]
        
        AssertEqualReadable(exportedItems, expectedItems)
    }
}
