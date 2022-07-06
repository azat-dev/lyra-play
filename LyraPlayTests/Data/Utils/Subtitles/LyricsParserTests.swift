//
//  LyricsParserTests.swift
//  LyraPlayTests
//
//  Created by Azat Kaiumov on 06.07.22.
//

import XCTest
import LyraPlay


class LyricsParserTests: XCTestCase {

    typealias SUT = SubtitlesParser
    
    func createSUT() -> SUT {
        
        let parser = LyricsParser()
        detectMemoryLeak(instance: parser)
        
        return parser
    }
    
    func testParseEmptyLyrics() async throws {
        
        let parser = createSUT()
        
        let text = ""
        
        let result = await parser.parse(text)
        let parsedSubtitles = try AssertResultSucceded(result)
        
        XCTAssertEqual(parsedSubtitles.sentences.count, 0)
    }
    
    func testParseNormalLyricsWithoutIdTags() async throws {
        
        let parser = createSUT()
        
        let text = """
        [00:12.00]Line 1 lyrics
        [00:17.20]Line 2 lyrics
        [00:21.10]Line 3 lyrics
        """
        
        let result = await parser.parse(text)
        let parsedSubtitles = try AssertResultSucceded(result)
        
        
        let expecteSubtitles = Subtitles(
            sentences: [
                .init(
                    startTime: 12,
                    duration: 0,
                    text: .notSynced(text: "Line 1 lyrics")
                ),
                .init(
                    startTime: 17.2,
                    duration: 0,
                    text: .notSynced(text: "Line 2 lyrics")
                ),
                .init(
                    startTime: 21.10,
                    duration: 0,
                    text: .notSynced(text: "Line 3 lyrics")
                )
            ]
        )
        
        XCTAssertEqual(parsedSubtitles.sentences.count, expecteSubtitles.sentences.count)
        XCTAssertEqual(parsedSubtitles, expecteSubtitles)
    }
}
