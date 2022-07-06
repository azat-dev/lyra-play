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
    
    func testParseNormalLyrics() async throws {
        
        let parser = createSUT()
        
        let text = """
        
        [ar: Test Artist]
        [al: Test Album]
        [au: Test]
        [length: 2:58]
        [by: lrc-maker]
        [ti: Test Test]

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
    
    func testParseEnhancedLyrics() async throws {
        
        let parser = createSUT()
        
        let text = """
        
        [ar: Test Artist]
        [al: Test Album]
        [au: Test]
        [length: 2:58]
        [by: test]
        [ti: Test Test]

        [00:00.00] <00:00.04> Word11 <00:00.16> Word12 <00:00.82> Word13
        
        [00:06.47] <00:07.67> Word21 <00:07.94> Word22
        
        [00:13.34] <00:14.32> Word31
        [00:15.34] <00:16.32>

        """
        
        let result = await parser.parse(text)
        let parsedSubtitles = try AssertResultSucceded(result)
        
        
        let expecteSubtitles = Subtitles(
            sentences: [
                .init(
                    startTime: 0,
                    duration: 0,
                    text: .synced(items: [
                        .init(startTime: 0.04, duration: 0, text: "Word11"),
                        .init(startTime: 0.16, duration: 0, text: "Word12"),
                        .init(startTime: 0.82, duration: 0, text: "Word13"),
                    ])
                ),
                .init(
                    startTime: 7.67,
                    duration: 0,
                    text: .synced(items: [
                        .init(startTime: 7.67, duration: 0, text: "Word21"),
                        .init(startTime: 7.94, duration: 0, text: "Word22"),
                    ])
                ),
                .init(
                    startTime: 13.34,
                    duration: 0,
                    text: .synced(items: [
                        .init(startTime: 14.32, duration: 0, text: "Word31"),
                    ])
                )
            ]
        )
        
        XCTAssertEqual(parsedSubtitles.sentences.count, expecteSubtitles.sentences.count)
        XCTAssertEqual(parsedSubtitles.sentences[0].text, expecteSubtitles.sentences[0].text)
    }
}
