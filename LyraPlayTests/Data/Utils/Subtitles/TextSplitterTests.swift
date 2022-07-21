//
//  TextSplitterTests.swift
//  LyraPlayTests
//
//  Created by Azat Kaiumov on 17.07.22.
//

import Foundation
import XCTest
import LyraPlay

class TextSplitterTests: XCTestCase {
    
    typealias SUT = TextSplitter
    
    func createSUT() -> SUT {
        
        let textSplitter = DefaultTextSplitter()
        detectMemoryLeak(instance: textSplitter)
        
        return textSplitter
    }
    
    func testSplitEmptyText() throws {
        
        let sut = createSUT()
        let result = sut.split(text: "")
        XCTAssertEqual(result, [])
    }
    
    func item(type: TextComponent.ComponentType, text: String, component: String) -> TextComponent {
        
        return .init(type: type, range: text.range(of: component)!)
    }
    
    func testSplitText() throws {
        
        let text = """
        Is this project long-term?
        "Hello, Mike!"
        """
        
        let expectedItems: [ExpectedTextComponent] = [
            .init(type: .word, text: "Is"),
            .init(type: .space, text: " "),
            .init(type: .word, text: "this"),
            .init(type: .space, text: " "),
            .init(type: .word, text: "project"),
            .init(type: .space, text: " "),
            .init(type: .word, text: "long"),
            .init(type: .specialCharacter, text: "-"),
            .init(type: .word, text: "term"),
            .init(type: .specialCharacter, text: "?"),
            .init(type: .space, text: "\n"),
            .init(type: .specialCharacter, text: "\""),
            .init(type: .word, text: "Hello"),
            .init(type: .specialCharacter, text: ","),
            .init(type: .space, text: " "),
            .init(type: .word, text: "Mike"),
            .init(type: .specialCharacter, text: "!"),
            .init(type: .specialCharacter, text: "\""),
        ]

        let sut = createSUT()
        let splitResult = sut.split(text: text)
        let result = splitResult.map { ExpectedTextComponent(from: $0, text: text) }
        
        XCTAssertEqual(result.count, expectedItems.count)
        
        for (index, expectedItem) in expectedItems.enumerated() {
            
            guard index < result.count else {
                break
            }
            
            let item = result[index]
            
            XCTAssertEqual(item, expectedItem)
        }
    }
}

// MARK: - Helpers

struct ExpectedTextComponent: Equatable {
    
    var type: TextComponent.ComponentType
    var text: String
    
    internal init(type: TextComponent.ComponentType, text: String) {
        self.type = type
        self.text = text
    }

    init(from item: TextComponent, text: String) {
        
        self.type = item.type
        self.text = String(text[item.range])
    }
}
