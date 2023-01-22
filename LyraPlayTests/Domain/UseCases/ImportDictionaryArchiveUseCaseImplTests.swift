//
//  ImportDictionaryArchiveUseCaseImplTests.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 21.01.2023.
//

import Foundation
import XCTest
import Mockingbird
import LyraPlay

class ImportDictionaryArchiveUseCaseImplTests: XCTestCase {

    typealias SUT = (
        useCase: ImportDictionaryArchiveUseCase,
        dictionaryRepository: DictionaryRepositoryMock,
        dictionaryArchiveParser: DictionaryArchiveParserMock
    )

    // MARK: - Methods

    func createSUT() -> SUT {

        let dictionaryRepository = mock(DictionaryRepository.self)

        let dictionaryArchiveParser = mock(DictionaryArchiveParser.self)

        let useCase = ImportDictionaryArchiveUseCaseImpl(
            dictionaryRepository: dictionaryRepository,
            dictionaryArchiveParser: dictionaryArchiveParser
        )

        detectMemoryLeak(instance: useCase)

        return (
            useCase: useCase,
            dictionaryRepository: dictionaryRepository,
            dictionaryArchiveParser: dictionaryArchiveParser
        )
    }
    
    func test_import__wrong_data() async throws {
        
        // Given
        let sut = createSUT()
        
        let data = "wrong".data(using: .utf8)!
        
        given(await sut.dictionaryRepository.listItems())
            .willReturn(.success([]))
        
        given(await sut.dictionaryArchiveParser.parse(data: any()))
            .willReturn(.failure(NSError()))
        
        // When
        let result = await sut.useCase.importArchive(data: data)
        
        // Then
        let error = try AssertResultFailed(result)
        
        guard case .wrongDataFormat = error else {
            XCTFail("Wrong error type \(error)")
            return
        }
    }
    
    func test_import__correct_data() async throws {
        
        // Given
        let sut = createSUT()

        let data = "correct".data(using: .utf8)!
        
        given(await sut.dictionaryRepository.listItems())
            .willReturn(.success([]))
        
        given(await sut.dictionaryRepository.searchItems(with: any()))
            .willReturn(.success([]))
        
        given(await sut.dictionaryArchiveParser.parse(data: any()))
            .willReturn(.success([]))
        
        // When
        let result = await sut.useCase.importArchive(data: data)
        
        // Then
        let _ = try AssertResultSucceded(result)
    }
}
