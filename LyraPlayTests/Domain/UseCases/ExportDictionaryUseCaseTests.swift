//
//  ExportDictionaryUseCaseTests.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 17.01.2023.
//

import Foundation
import XCTest
import Mockingbird
import LyraPlay

class ExportDictionaryUseCaseTests: XCTestCase {

    typealias SUT = (
        useCase: ExportDictionaryUseCase,
        dictionaryRepository: DictionaryRepositoryOutputListMock,
        dictionaryExporter: DictionaryExporterMock
    )

    // MARK: - Methods

    func createSUT() -> SUT {

        let dictionaryRepository = mock(DictionaryRepositoryOutputList.self)

        let dictionaryExporter = mock(DictionaryExporter.self)

        let useCase = ExportDictionaryUseCaseImpl(
            dictionaryRepository: dictionaryRepository,
            dictionaryExporter: dictionaryExporter
        )

        detectMemoryLeak(instance: useCase)

        return (
            useCase: useCase,
            dictionaryRepository: dictionaryRepository,
            dictionaryExporter: dictionaryExporter
        )
    }
    
    func test_export__fail_get_items() async throws {
        
        let sut = createSUT()
        
        // Given
        given(await sut.dictionaryRepository.listItems())
            .willReturn(.failure(.internalError(NSError(domain: "", code: 0))))
        
        given(sut.dictionaryExporter.export(repository: any()))
            .willReturn(.failure(NSError(domain: "", code: 0)))
        
        // When
        let result = sut.useCase.export()
        
        // Then
        let error = try AssertResultFailed(result)
        
        guard case .internalError = error else {
            XCTFail("Wrong error type: \(result)")
            return
        }
    }
    
    func test_export__success() async throws {
        
        let sut = createSUT()
        
        // Given
        let items: [ExportedDictionaryItem] = [
            .init(original: "test", translations: [ "test1" ])
        ]
        
        given(sut.dictionaryExporter.export(repository: any()))
            .willReturn(.success(items))

        // When
        let result = sut.useCase.export()
        
        // Then
        let receivedItems = try AssertResultSucceded(result)
        
        AssertEqualReadable(receivedItems, items)
    }
}
