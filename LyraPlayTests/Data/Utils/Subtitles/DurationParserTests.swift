//
//  DurationParserTests.swift
//  LyraPlayTests
//
//  Created by Azat Kaiumov on 06.07.22.
//

import Foundation
import XCTest
import LyraPlay

class DurationParserTests: XCTestCase {

    typealias SUT = DurationParser
    
    func createSUT() -> SUT {
        
        let parser = DurationParser()
        detectMemoryLeak(instance: parser)
        
        return parser
    }
    
    func testParseEmpty() async throws {
        
        let parser = createSUT()
        let parsed = parser.parse("")
        XCTAssertNil(parsed)
    }
    
    func testParseAlphanumeric() async throws {
        
        let parser = createSUT()
        let parsed = parser.parse("1A:2B")
        XCTAssertNil(parsed)
    }
    
    func assertValue(_ text: String, _ expectedValue: Double, file: StaticString = #filePath, line: UInt = #line) {
        
        let parser = createSUT()
        
        XCTAssertEqual(
            parser.parse(text),
            expectedValue,
            file: file,
            line: line
        )
    }
    
    func testParse() async {
        
        assertValue("0", 0)
        assertValue("0:0", 0)
        assertValue("0:00", 0)
        assertValue("00:0", 0)
        assertValue("0:00:00", 0)
        assertValue("00:00:00", 0)

        assertValue("1", 1)
        assertValue("1:00", 60)
        assertValue("1:01", 61)
        
        assertValue("1:01:01", 3661)
        assertValue("100:00:00", 3600 * 100)
        
        assertValue("0.1", 0.1)
        assertValue("0.001", 0.001)
        assertValue("1.001", 1.001)
    }
}
