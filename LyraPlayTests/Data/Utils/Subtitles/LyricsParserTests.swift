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
        parser: SubtitlesParser,
        textSplitter: TextSplitterMock
    )
    
    func createSUT() -> SUT {
        
        let textSplitter = TextSplitterMock()
        let parser = LyricsParser(textSplitter: textSplitter)
        detectMemoryLeak(instance: parser)
        
        return (
            parser,
            textSplitter
        )
    }
    
    func testParseEmptyLyrics() async throws {
        
        let sut = createSUT()
        
        let text = ""
        
        let result = await sut.parser.parse(text)
        let parsedSubtitles = try AssertResultSucceded(result)
        
        XCTAssertEqual(parsedSubtitles.sentences.count, 0)
    }
    
    func testParseNormalLyrics() async throws {
        
        let sut = createSUT()
        
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
        
        let result = await sut.parser.parse(text)
        let subtitlesResult = try AssertResultSucceded(result)
        let parsedSubtitles = ExpectedSubtitles(from: subtitlesResult)
        
        let expecteSubtitles = ExpectedSubtitles(
            sentences: [
                .init(
                    startTime: 12,
                    duration: nil,
                    text: "Line 1 lyrics"
                ),
                .init(
                    startTime: 17.2,
                    duration: nil,
                    text: "Line 2 lyrics"
                ),
                .init(
                    startTime: 21.10,
                    duration: nil,
                    text: "Line 3 lyrics"
                )
            ]
        )
        
        XCTAssertEqual(parsedSubtitles.sentences.count, expecteSubtitles.sentences.count)
        
        for (index, expectedSentence) in expecteSubtitles.sentences.enumerated() {
            
            XCTAssertEqual(parsedSubtitles.sentences[index], expectedSentence)
        }
    }
    
    func testParseEnhancedLyrics() async throws {
        
        let sut = createSUT()
        
        let line1 = " <00:00.04> Word11 <00:00.16> Word12 <00:00.82> Word13"
        let line2 = " <00:07.67> Word21 <00:07.94> Word22"
        let line3 = " <00:14.32> Word31"
        
        let text = """
        
        [ar: Test Artist]
        [al: Test Album]
        [au: Test]
        [length: 2:58]
        [by: test]
        [ti: Test Test]

        [00:00.00]\(line1)
        
        [00:06.47]\(line2)
        
        [00:13.34]\(line3)
        [00:15.34] <00:16.32>

        """
        
        let result = await sut.parser.parse(text)
        let subtitlesResult = try AssertResultSucceded(result)
        let parsedSubtitles = ExpectedSubtitles(from: subtitlesResult)
        
        
        let expecteSubtitles = ExpectedSubtitles(
            sentences: [
                .init(
                    startTime: 0,
                    duration: nil,
                    text: "Word11 Word12 Word13",
                    timeMarks: [
                        .init(startTime: 0.04, text: "Word11"),
                        .init(startTime: 0.16, text: "Word12"),
                        .init(startTime: 0.82, text: "Word13"),
                    ]
                ),
                .init(
                    startTime: 6.47,
                    duration: nil,
                    text: "Word21 Word22",
                    timeMarks: [
                        .init(startTime: 7.67, text: "Word21"),
                        .init(startTime: 7.94, text: "Word22"),
                    ]
                ),
                .init(
                    startTime: 13.34,
                    duration: nil,
                    text: "Word31",
                    timeMarks: [
                        .init(startTime: 14.32, text: "Word31"),
                    ]
                )
            ]
        )
        
        XCTAssertEqual(parsedSubtitles.sentences.count, expecteSubtitles.sentences.count)
        
        for (index, expectedSentence) in expecteSubtitles.sentences.enumerated() {
            
            let sentence = parsedSubtitles.sentences[index]
            
            XCTAssertEqual(sentence.startTime, expectedSentence.startTime)
            XCTAssertEqual(sentence.duration, expectedSentence.duration)
            XCTAssertEqual(sentence.text, expectedSentence.text)
            
            
//            XCTAssertEqual(sentence, expectedSentence)
            
            for (index, expectedTimeMark) in (expectedSentence.timeMarks ?? []).enumerated() {
                
                guard
                    let timeMarks = sentence.timeMarks,
                    index < timeMarks.count
                else {
                    
                    XCTFail("No time mark at \(index)")
                    break
                }
                
                XCTAssertEqual(timeMarks[index], expectedTimeMark)
            }
            
            XCTAssertEqual(sentence.timeMarks?.count, expectedSentence.timeMarks?.count, "Index \(index)")
        }
    }
}


// MARK: - Helpers

struct ExpectedSubtitles {

    var sentences: [ExpectedSentence]

    init(sentences: [ExpectedSentence]) {
        self.sentences = sentences
    }
    
    init(from subtitles: Subtitles) {
        
        self.sentences = subtitles.sentences.map { .init(from: $0) }
    }
}

struct ExpectedSentence: Equatable {
    
    var startTime: TimeInterval
    var duration: TimeInterval?
    var text: String
    var timeMarks: [ExpectedTimeMark]?
    
    init(
        startTime: TimeInterval,
        duration: TimeInterval? = nil,
        text: String,
        timeMarks: [ExpectedTimeMark]? = nil
    ) {
        
        self.startTime = startTime
        self.text = text
        self.duration = duration
        self.timeMarks = timeMarks
    }

    init(from sentence: Subtitles.Sentence) {
     
        startTime = sentence.startTime
        duration = sentence.duration
        text = sentence.text
        timeMarks = sentence.timeMarks?.map { ExpectedTimeMark(from: $0, text: sentence.text) }
    }
}

struct ExpectedTimeMark: Equatable {
    
    var startTime: TimeInterval?
    var duration: TimeInterval?
    var text: String?
    
    init(
        startTime: TimeInterval? = nil,
        duration: TimeInterval? = nil,
        text: String? = nil
    ) {
        
        self.startTime = startTime
        self.duration = duration
        self.text = text
    }

    init(from timeMark: Subtitles.TimeMark, text: String) {
        
        self.startTime = timeMark.startTime
        self.duration = timeMark.duration
        
        print(NSRange(timeMark.range, in: text))
        self.text = String(text[timeMark.range])
    }
}
