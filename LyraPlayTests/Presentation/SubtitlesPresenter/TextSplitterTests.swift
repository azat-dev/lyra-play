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
        Word1,word2,word3.Word4 Word5-Word6 -Word7
        word8
        """
        
        let dummyIndex = (text.startIndex..<text.endIndex)

        let expectedItems: [TextComponent] = [
            .init(type: .word, range: dummyIndex, text: "Word1"),
            .init(type: .specialCharacter, range: dummyIndex, text: ","),
            .init(type: .word, range: dummyIndex, text: "word2"),
            .init(type: .specialCharacter, range: dummyIndex, text: ","),
            .init(type: .word, range: dummyIndex, text: "word3"),
            .init(type: .specialCharacter, range: dummyIndex, text: "."),
            .init(type: .word, range: dummyIndex, text: "Word4"),
            .init(type: .space, range: dummyIndex, text: " "),
            .init(type: .word, range: dummyIndex, text: "Word5-Word6"),
            .init(type: .space, range: dummyIndex, text: " "),
            .init(type: .specialCharacter, range: dummyIndex, text: "-"),
            .init(type: .word, range: dummyIndex, text: "Word7"),
            .init(type: .newLine, range: dummyIndex, text: "\n"),
            .init(type: .word, range: dummyIndex, text: "word8")
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
