//
//  DictionaryArchiveParserTests.swift
//  LyraPlayTests
//
//  Created by Azat Kaiumov on 21.01.23.
//

import Foundation
import XCTest

import LyraPlay

class DictionaryArchiveParserTests: XCTestCase {
    
    typealias SUT = DictionaryArchiveParser
    
    func createSUT() -> SUT {
        
        return DictionaryArchiveParserImpl()
    }
    
    func test_parse__wrong_data() async throws {
        
        let sut = createSUT()
        
        // Given
        let wrongData = "test".data(using: .utf8)
        
        // When
        let result = await sut.parse(data: wrongData!)
        
        // Then
        let _ = try AssertResultFailed(result)
    }
    
    func anyData() -> Data {
        
        let items: [ExportedDictionaryItem] = [
            .init(original: "original", translations: ["translation"])
        ]
        
        let encoder = JSONEncoder()
        return try! encoder.encode(items)
    }
    
    func test_parse__correct_data() async throws {
        
        let sut = createSUT()
        
        // Given
        let correctData = anyData()
        
        // When
        let result = await sut.parse(data: correctData)
        
        // Then
        let _ = try AssertResultSucceded(result)
    }
}
