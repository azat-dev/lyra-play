//
//  LyricsParserTests.swift
//  LyraPlayTests
//
//  Created by Azat Kaiumov on 06.07.22.
//

import XCTest
import LyraPlay

class LyricsParserTests: XCTestCase {

    typealias SUT = (
        parser: SubtitlesParser
    )
    
    func createSUT() -> SUT {
        
        let parser = LyricsParser()
        detectMemoryLeak(instance: parser)
        
        return (parser)
    }
    
    func testParseEmptyLyrics() async throws {
        
        let (parser) = createSUT()
        
        let text = ""
        
        let result = await parser.parse(text)
        let parsedSubtitles = try AssertResultSucceded(result)
        
        XCTAssertEqual(parsedSubtitles.sentences, [])
    }
}
