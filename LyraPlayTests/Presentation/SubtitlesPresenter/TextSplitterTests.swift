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
        
        let textSplitter = DefaultTextSplitter(
            sentence
        )
        detectMemoryLeak(instance: textSplitter)
        
        return textSplitter
    }
    
    func testSplitEmptyText() async throws {
        
        let sut = createSUT()
        let result = await sut.split(text: "")
        XCTAssertEqual(result, [])
    }
    
    func testSplitText() async throws {
        
        let text = """
        Word1,word2,word3.Word4 Word5-Word6 -Word7
        word8
        """
        
        let expectedItems: [TextComponent] = [
            .word(range: (text.startIndex...text.startIndex), text: "Word1"),
            .specialCharacter(range: (text.startIndex...text.startIndex), text: ","),
            .word(range: (text.startIndex...text.startIndex), text: "word2"),
            .specialCharacter(range: (text.startIndex...text.startIndex), text: ","),
            .word(range: (text.startIndex...text.startIndex), text: "word3"),
            .specialCharacter(range: (text.startIndex...text.startIndex), text: "."),
            .word(range: (text.startIndex...text.startIndex), text: "Word4"),
            .space(range: (text.startIndex...text.startIndex), text: " "),
            .word(range: (text.startIndex...text.startIndex), text: "Word5-Word6"),
            .space(range: (text.startIndex...text.startIndex), text: " "),
            .specialCharacter(range: (text.startIndex...text.startIndex), text: "-"),
            .word(range: (text.startIndex...text.startIndex), text: "Word7")
        ]

        let sut = createSUT()
        let result = sut.split(text: text)
        
        XCTAssertEqual(result, expectedItems)
    }
}

public enum TextComponent: Equatable {
    
    case space(range: ClosedRange<String.Index>, text: String)
    case word(range: ClosedRange<String.Index>, text: String)
    case specialCharacter(range: ClosedRange<String.Index>, text: String)
}
