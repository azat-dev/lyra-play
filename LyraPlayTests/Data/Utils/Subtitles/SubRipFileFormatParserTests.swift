//
//  SubRipFileFormatParserTests.swift
//  LyraPlayTests
//
//  Created by Azat Kaiumov on 20.08.22.
//

import XCTest
import Foundation
import LyraPlay

class SubRipFileFormatParserTests: XCTestCase {

    typealias SUT = (
        parser: SubtitlesParser,
        textSplitter: TextSplitterMock
    )
    
    func createSUT() -> SUT {
        
        let textSplitter = TextSplitterMock()
        let parser = SubRipFileFormatParser(textSplitter: textSplitter)
        detectMemoryLeak(instance: parser)
        
        return (
            parser,
            textSplitter
        )
    }
    
    func test_parse_empty() async throws {
        
        // Given
        // Empty text
        let sut = createSUT()
        let text = ""

        // When
        let result = await sut.parser.parse(text, fileName: "filename.srt")
        let parsedSubtitles = try AssertResultSucceded(result)
        
        // Thne
        let expectedSubtitles = ExpectedSubtitles(duration: 0, sentences: [])
        AssertEqualReadable(.init(from: parsedSubtitles), expectedSubtitles)
    }
    
    func test_parse__not_empty() async throws {
        
        // Given not empty file
        let sut = createSUT()
        let text = """
        
        1
        00:02:16,612 --> 00:02:19,376
        Senator, we're making
        our final approach into Coruscant.
           
        
        2
        00:02:19,482 --> 00:02:21,609
        Very good, Lieutenant.
        """
        
        // When
        let result = await sut.parser.parse(text, fileName: "test.srt")
        
        // Then
        let subtitlesResult = try AssertResultSucceded(result)
        let parsedSubtitles = ExpectedSubtitles(from: subtitlesResult)
        
        let expecteSubtitles = ExpectedSubtitles(
            duration: 2 * 60 + 21.609,
            sentences: [
                .init(
                    startTime: TimeInterval(2 * 60 + 16.612),
                    duration: TimeInterval(2 * 60 + 19.376) - TimeInterval(2 * 60 + 16.612),
                    text: "Senator, we're making\nour final approach into Coruscant."
                ),
                .init(
                    startTime: TimeInterval(2 * 60 + 19.482),
                    duration: TimeInterval(2 * 60 + 21.609) - TimeInterval(2 * 60 + 19.482),
                    text: "Very good, Lieutenant."
                )
            ]
        )

        AssertEqualReadable(parsedSubtitles, expecteSubtitles)
    }
}
