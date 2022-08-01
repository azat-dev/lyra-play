//
//  ProvideTranslationsForSubtitlesUseCaseTests.swift
//  LyraPlayTests
//
//  Created by Azat Kaiumov on 21.07.22.
//

import Foundation
import XCTest
import LyraPlay

class ProvideTranslationsForSubtitlesUseCaseTests: XCTestCase {
    
    typealias SUT = (
        useCase: ProvideTranslationsForSubtitlesUseCase,
        dictionaryRepository: DictionaryRepositoryMock
    )
    
    func createSUT() -> SUT {
        
        let dictionaryRepository = DictionaryRepositoryMock()
        
        let useCase = DefaultProvideTranslationsForSubtitlesUseCase(
            dictionaryRepository: dictionaryRepository
        )
        
        detectMemoryLeak(instance: useCase)
        
        return (
            useCase,
            dictionaryRepository
        )
    }
    
    func testFetchTranslationsForEmptySubtitles() async throws {
        
        let sut = createSUT()
        
        let mediaId = UUID()
        
        let subtitles = Subtitles(duration: 0, sentences: [])
        let resultPrepare = await sut.useCase.prepare(for: mediaId, subtitles: subtitles)
        try AssertResultSucceded(resultPrepare)
        
        let resultTranslations = await sut.useCase.fetchTranslations(words: [])
        let items = try AssertResultSucceded(resultTranslations)
        
        XCTAssertTrue(items.isEmpty)
    }
    
    private func anyDictionaryItem(originalText: String, translation: String, id: UUID? = nil) -> DictionaryItem {
        
        return .init(
            id: id ?? UUID(),
            createdAt: nil,
            updatedAt: nil,
            originalText: originalText,
            lemma: originalText,
            language: "",
            translations: [
                TranslationItem(text: "translation")
            ]
        )
    }
    
    func testFetchGlobalTranslations() async throws {
        
        let sut = createSUT()
        let mediaId = UUID()
        
        let numberOfWords = 2
        let dictionaryIds = (0..<numberOfWords).map { _ in UUID() }
        
        let expectedTranslations = (0..<numberOfWords).map { index in
            
            return ExpectedTranslation(
                dictionaryItemId: dictionaryIds[index],
                originalText: "original\(index)",
                lemma: "lemma\(index)",
                translation: "translation\(index)"
            )
        }
        
        sut.dictionaryRepository.items = (0..<numberOfWords).map { index in
            
            let id = dictionaryIds[index]
            
            return anyDictionaryItem(
                originalText: "original\(index)",
                translation: "translation\(index)",
                id: id
            )
        }
        
        let text = expectedTranslations
            .map { item in item.originalText }
            .joined(separator: " ")
        
        let components = expectedTranslations.map { item in
            TextComponent(type: .word, range: text.range(of: item.originalText)!)
        }
        
        let subtitles = Subtitles(
            duration: 0.1,
            sentences: [
                .init(
                    startTime: 0,
                    text: text,
                    components: components
                )
            ]
        )
        
        let resultPrepare = await sut.useCase.prepare(for: mediaId, subtitles: subtitles)
        try AssertResultSucceded(resultPrepare)
        
        let resultTranslations = await sut.useCase.fetchTranslations(words: [])
        let items = try AssertResultSucceded(resultTranslations)
        
        XCTAssertEqual(items.count, numberOfWords)
        
        for expectedTranslation in expectedTranslations {
            
            let item = items[expectedTranslation.originalText]
            
            let unwrappedItem = try XCTUnwrap(item)
            XCTAssertEqual(.init(from: unwrappedItem), expectedTranslation)
        }
    }
}

// MARK: - Mocks

final class DictionaryRepositoryMock: DictionaryRepository {
    
    var items = [DictionaryItem]()
    
    func putItem(_ item: DictionaryItem) async -> Result<DictionaryItem, DictionaryRepositoryError> {
        
        let index = items.firstIndex { $0.id == item.id }
        
        guard let index = index else {
            
            items.append(item)
            return .success(item)
        }
        
        items[index] = item
        return .success(item)
    }
    
    func getItem(id: UUID) async -> Result<DictionaryItem, DictionaryRepositoryError> {
        
        let item = items.first { $0.id == id }
        
        guard let item = item else {
            
            return .failure(.itemNotFound)
        }
        
        return .success(item)
    }
    
    func deleteItem(id: UUID) async -> Result<Void, DictionaryRepositoryError> {
        
        let index = items.firstIndex { $0.id == id }
        
        guard let index = index else {
            
            return .failure(.itemNotFound)
        }

        items.remove(at: index)
        return .success(())
    }
    
    func searchItems(with: [DictionaryItemFilter]) async -> Result<[DictionaryItem], DictionaryRepositoryError> {
        
        return .success([])
    }
}

// MARK: - Helpers

struct ExpectedTranslation: Equatable {
    
    var dictionaryItemId: UUID
    var originalText: String
    var lemma: String
    var translation: String
    
    init(
        dictionaryItemId: UUID,
        originalText: String,
        lemma: String,
        translation: String
    ) {
        
        self.dictionaryItemId = dictionaryItemId
        self.originalText = originalText
        self.lemma = lemma
        self.translation = translation
    }

    init(from item: SubtitlesTranslation) {
        
        self.dictionaryItemId = item.dictionaryItemId
        self.originalText = item.originalText
        self.lemma = item.lemma
        self.translation = item.translation
    }
}
