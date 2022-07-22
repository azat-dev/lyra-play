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
        
        let lemmatizer = DefaultLemmatizer()
        detectMemoryLeak(instance: lemmatizer)
        
        return lemmatizer
    }
    
    
    func testLemmatizeEmptyText() async throws {

        let sut = createSUT()
        
        let text = ""
        let result = sut.lemmatize(text: text)
        
        XCTAssertEqual(result.map { ExpectedLemma(from: $0, text: text) }, [])
    }
    
    func testLemmatize() async throws {

        let text = "What is she doing? She speaks English very well"
        let sut = createSUT()
        
        let result = sut.lemmatize(text: text)
        
        let expectedItems: [ExpectedLemma] = []
        
        XCTAssertEqual(result.map { .init(from: $0, text: text) }, expectedItems)
    }
}

// MARK: - Helpers

struct ExpectedLemma: Equatable {
    
    var lemma: String?
    var text: String
    
    init(lemma: String? = nil, text: String) {
        
        self.lemma = lemma
        self.text = text
    }
    
    init(from item: LemmaItem, text: String) {
        
        self.lemma = item.lemma
        self.text = text[item.range]
    }
}
