//
//  LemmatizerTests.swift
//  LyraPlayTests
//
//  Created by Azat Kaiumov on 22.07.22.
//

import Foundation
import XCTest
import LyraPlay

class LemmatizerTests: XCTestCase {
    
    typealias SUT = Lemmatizer
    
    func createSUT() -> SUT {
        
        let lemmatizer = LemmatizerImpl()
        detectMemoryLeak(instance: lemmatizer)
        
        return lemmatizer
    }
    
    func test_lemmatize__empty_text() async throws {

        let sut = createSUT()
        
        // Given
        let emptyText = ""
        
        // When
        let result = sut.lemmatize(text: emptyText)
        
        // Then
        let receivedItems = result.map { ExpectedLemma(from: $0, text: emptyText) }
        XCTAssertEqual(receivedItems, [])
    }
    
    func test_lemmatize__not_empty_text() async throws {

        // Given
        let notEmptyText = "What is she doing? She speaks English very well"
        let sut = createSUT()
        
        // When
        let result = sut.lemmatize(text: notEmptyText)
        
        // Then
        let expectedItems: [ExpectedLemma] = [
            
            .init(lemma: "what", text: "What"),
            .init(lemma: "be", text: "is"),
            .init(lemma: "she", text: "she"),
            .init(lemma: "do", text: "doing"),
            
            .init(lemma: "she", text: "She"),
            .init(lemma: "speak", text: "speaks"),
            .init(lemma: "English", text: "English"),
            .init(lemma: "very", text: "very"),
            .init(lemma: "well", text: "well"),
        ]
        
        let receivedItems = result.map { ExpectedLemma(from: $0, text: notEmptyText) }
        AssertEqualReadable(receivedItems, expectedItems)
    }
}

// MARK: - Helpers

struct ExpectedLemma: Equatable {
    
    var lemma: String
    var text: String
    
    init(lemma: String, text: String) {
        
        self.lemma = lemma
        self.text = text
    }
    
    init(from item: LemmaItem, text: String) {
        
        self.lemma = item.lemma
        self.text = String(text[item.range])
    }
}
