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
    
    func testSplitText() throws {
        
        let text = """
        Is this project long-term?
        "Hello, Mike!"
        """
        
        let dummyIndex = (text.startIndex..<text.endIndex)

        let expectedItems: [TextComponent] = [
            .init(type: .word, range: dummyIndex, text: "Is"),
            .init(type: .space, range: dummyIndex, text: " "),
            .init(type: .word, range: dummyIndex, text: "this"),
            .init(type: .space, range: dummyIndex, text: " "),
            .init(type: .word, range: dummyIndex, text: "project"),
            .init(type: .space, range: dummyIndex, text: " "),
            .init(type: .word, range: dummyIndex, text: "long"),
            .init(type: .specialCharacter, range: dummyIndex, text: "-"),
            .init(type: .word, range: dummyIndex, text: "term"),
            .init(type: .specialCharacter, range: dummyIndex, text: "?"),
            .init(type: .space, range: dummyIndex, text: "\n"),
            .init(type: .specialCharacter, range: dummyIndex, text: "\""),
            .init(type: .word, range: dummyIndex, text: "Hello"),
            .init(type: .specialCharacter, range: dummyIndex, text: ","),
            .init(type: .space, range: dummyIndex, text: " "),
            .init(type: .word, range: dummyIndex, text: "Mike"),
            .init(type: .specialCharacter, range: dummyIndex, text: "!"),
            .init(type: .specialCharacter, range: dummyIndex, text: "\""),
        ]

        let sut = createSUT()
        let result = sut.split(text: text)
        
        XCTAssertEqual(result.count, expectedItems.count)
        
        for (index, expectedItem) in expectedItems.enumerated() {
            
            guard index < result.count else {
                break
            }
            
            let item = result[index]
            
            XCTAssertEqual(item.type, expectedItem.type)
            XCTAssertEqual(item.text, expectedItem.text)
            
            let rangeText = text[item.range]
            XCTAssertEqual(String(rangeText), expectedItem.text)
        }
    }
}
