//
//  SubtitlesTimeSlotsParserTests.swift
//  LyraPlayTests
//
//  Created by Azat Kaiumov on 04.08.22.
//

import Foundation
import XCTest
import LyraPlay

class SubtitlesTimeSlotsParserTests: XCTestCase {
    
    typealias SUT = SubtitlesTimeSlotsParser
    
    func createSUT() -> SUT {
        
        let parser = SubtitlesTimeSlotsParser()
        detectMemoryLeak(instance: parser)
        
        return parser
    }
    
    func test_parse__empty_subtitles() async throws {
        
        let emptySubtitles = Subtitles(duration: 0, sentences: [])

        AssertEqualReadable(
            createSUT().parse(from: emptySubtitles),
            [
                .init(index: 0, timeRange: (0..<0))
            ]
        )
    }
    
    func test_parse__sentence_starts_from_beginning() async throws {
        
        let subtitles = Subtitles(duration: 10, sentences: [
            .anySentence(at: 0)
        ])
        
        AssertEqualReadable(
            createSUT().parse(from: subtitles),
            [
                .init(
                    index: 0,
                    timeRange: (0..<10),
                    subtitlesPosition: .init(
                        sentenceIndex: 0,
                        timeMarkIndex: nil
                    )
                ),
                .init(
                    index: 1,
                    timeRange: (10..<10)
                )
            ]
        )
    }
    
    func test_parse__sentence_doesnt_start_from_beginning() async throws {
        
        let subtitles = Subtitles(duration: 10, sentences: [
            .anySentence(at: 1)
        ])
        
        AssertEqualReadable(
            createSUT().parse(from: subtitles),
            [
                .init(index: 0, timeRange: (0..<1)),
                .init(
                    index: 1,
                    timeRange: (1..<10),
                    subtitlesPosition: .init(
                        sentenceIndex: 0,
                        timeMarkIndex: nil
                    )
                ),
                .init(index: 2, timeRange: (10..<10)),
            ]
        )
    }
    
    func test_parse__sentence_with_duration() async throws {
        
        let subtitles = Subtitles(duration: 10, sentences: [
            .anySentence(at: 0, duration: 5)
        ])
        
        AssertEqualReadable(
            createSUT().parse(from: subtitles),
            [
                .init(
                    index: 0,
                    timeRange: (0..<5),
                    subtitlesPosition: .init(sentenceIndex: 0, timeMarkIndex: nil)
                ),
                .init(
                    index: 1,
                    timeRange: (5..<10)
                ),
                .init(
                    index: 2,
                    timeRange: (10..<10)
                )
            ]
        )
    }
    
    func test_parse__sentence_with_time_mark() async throws {
        
        let subtitles = Subtitles(duration: 10, sentences: [
            .anySentence(at: 0, timeMarks: [
                .anyTimeMark(at: 1, duration: 3)
            ])
        ])
        
        AssertEqualReadable(
            createSUT().parse(from: subtitles),
            [
                .init(
                    index: 0,
                    timeRange: (0..<1),
                    subtitlesPosition: .init(sentenceIndex: 0, timeMarkIndex: nil)
                ),
                .init(
                    index: 1,
                    timeRange: (1..<4),
                    subtitlesPosition: .init(sentenceIndex: 0, timeMarkIndex: 0)
                ),
                .init(
                    index: 2,
                    timeRange: (4..<10),
                    subtitlesPosition: .init(sentenceIndex: 0, timeMarkIndex: nil)
                ),
                .init(
                    index: 3,
                    timeRange: (10..<10)
                ),
            ]
        )
    }
    
    func test_parse__sentence_with_time_marks_and_duration() async throws {
        
        let subtitles = Subtitles(duration: 10, sentences: [
            .anySentence(at: 0, duration: 5, timeMarks: [
                .anyTimeMark(at: 1, duration: 3)
            ])
        ])
        
        AssertEqualReadable(
            createSUT().parse(from: subtitles),
            [
                .init(
                    index: 0,
                    timeRange: (0..<1),
                    subtitlesPosition: .init(sentenceIndex: 0, timeMarkIndex: nil)
                ),
                .init(
                    index: 1,
                    timeRange: (1..<4),
                    subtitlesPosition: .init(sentenceIndex: 0, timeMarkIndex: 0)
                ),
                .init(
                    index: 2,
                    timeRange: (4..<5),
                    subtitlesPosition: .init(sentenceIndex: 0, timeMarkIndex: nil)
                ),
                .init(
                    index: 3,
                    timeRange: (5..<10),
                    subtitlesPosition: nil
                ),
                .init(
                    index: 4,
                    timeRange: (10..<10)
                ),
            ]
        )
    }
    
    func test_parse__with_spaces_between_sentences() async throws {
        
        let subtitles = Subtitles(duration: 10, sentences: [
            .anySentence(at: 0, duration: 1),
            .anySentence(at: 2, duration: 1),
            .anySentence(at: 4, duration: 1),
        ])
        
        AssertEqualReadable(
            createSUT().parse(from: subtitles),
            [
                .init(
                    index: 0,
                    timeRange: (0..<1),
                    subtitlesPosition: .init(sentenceIndex: 0, timeMarkIndex: nil)
                ),
                .init(
                    index: 1,
                    timeRange: (1..<2),
                    subtitlesPosition: nil
                ),
                .init(
                    index: 2,
                    timeRange: (2..<3),
                    subtitlesPosition: .init(sentenceIndex: 1, timeMarkIndex: nil)
                ),
                .init(
                    index: 3,
                    timeRange: (3..<4),
                    subtitlesPosition: nil
                ),
                .init(
                    index: 4,
                    timeRange: (4..<5),
                    subtitlesPosition: .init(sentenceIndex: 2, timeMarkIndex: nil)
                ),
                .init(
                    index: 5,
                    timeRange: (5..<10),
                    subtitlesPosition: nil
                ),
                .init(
                    index: 6,
                    timeRange: (10..<10)
                ),
            ]
        )
    }
    
    func test_parse__with_no_spaces_between_sentences() async throws {
        
        let subtitles = Subtitles(duration: 10, sentences: [
            .anySentence(at: 0, duration: 1),
            .anySentence(at: 1, duration: 1),
            .anySentence(at: 2, duration: 1),
        ])
        
        AssertEqualReadable(
            createSUT().parse(from: subtitles),
            [
                .init(
                    index: 0,
                    timeRange: (0..<1),
                    subtitlesPosition: .init(sentenceIndex: 0, timeMarkIndex: nil)
                ),
                .init(
                    index: 1,
                    timeRange: (1..<2),
                    subtitlesPosition: .init(sentenceIndex: 1, timeMarkIndex: nil)
                ),
                .init(
                    index: 2,
                    timeRange: (2..<3),
                    subtitlesPosition: .init(sentenceIndex: 2, timeMarkIndex: nil)
                ),
                .init(
                    index: 3,
                    timeRange: (3..<10),
                    subtitlesPosition: nil
                ),
                .init(
                    index: 4,
                    timeRange: (10..<10)
                ),
            ]
        )
    }
    
    func test_parse__with_time_mark_with_same_time_as_sentence() async throws {
        
        let subtitles = Subtitles(duration: 10, sentences: [
            .anySentence(at: 0, duration: 2, timeMarks: [
                .anyTimeMark(at: 0)
            ]),
        ])
        
        AssertEqualReadable(
            createSUT().parse(from: subtitles),
            [
                .init(
                    index: 0,
                    timeRange: (0..<2),
                    subtitlesPosition: .init(sentenceIndex: 0, timeMarkIndex: 0)
                ),
                .init(
                    index: 1,
                    timeRange: (2..<10),
                    subtitlesPosition: nil
                ),
                .init(
                    index: 2,
                    timeRange: (10..<10)
                ),
            ]
        )
    }
    
    func test_parse__with_time_mark_with_different_time_from_sentence() async throws {
        
        let subtitles = Subtitles(duration: 10, sentences: [
            .anySentence(at: 0, duration: 2, timeMarks: [
                .anyTimeMark(at: 1)
            ]),
        ])
        
        AssertEqualReadable(
            createSUT().parse(from: subtitles),
            [
                .init(
                    index: 0,
                    timeRange: (0..<1),
                    subtitlesPosition: .init(sentenceIndex: 0, timeMarkIndex: nil)
                ),
                .init(
                    index: 1,
                    timeRange: (1..<2),
                    subtitlesPosition: .init(sentenceIndex: 0, timeMarkIndex: 0)
                ),
                .init(
                    index: 2,
                    timeRange: (2..<10),
                    subtitlesPosition: nil
                ),
                .init(
                    index: 3,
                    timeRange: (10..<10)
                ),
            ]
        )
    }
    
    func test_parse__with_space_between_time_marks() async throws {
        
        let subtitles = Subtitles(duration: 10, sentences: [
            .anySentence(at: 0, timeMarks: [
                .anyTimeMark(at: 1, duration: 1),
                .anyTimeMark(at: 3, duration: 1),
                .anyTimeMark(at: 5, duration: 1)
            ]),
        ])
        
        AssertEqualReadable(
            createSUT().parse(from: subtitles),
            [
                .init(
                    index: 0,
                    timeRange: (0..<1),
                    subtitlesPosition: .init(sentenceIndex: 0, timeMarkIndex: nil)
                ),
                .init(
                    index: 1,
                    timeRange: (1..<2),
                    subtitlesPosition: .init(sentenceIndex: 0, timeMarkIndex: 0)
                ),
                .init(
                    index: 2,
                    timeRange: (2..<3),
                    subtitlesPosition: .init(sentenceIndex: 0, timeMarkIndex: nil)
                ),
                .init(
                    index: 3,
                    timeRange: (3..<4),
                    subtitlesPosition: .init(sentenceIndex: 0, timeMarkIndex: 1)
                ),
                .init(
                    index: 4,
                    timeRange: (4..<5),
                    subtitlesPosition: .init(sentenceIndex: 0, timeMarkIndex: nil)
                ),
                .init(
                    index: 5,
                    timeRange: (5..<6),
                    subtitlesPosition: .init(sentenceIndex: 0, timeMarkIndex: 2)
                ),
                .init(
                    index: 6,
                    timeRange: (6..<10),
                    subtitlesPosition: .init(sentenceIndex: 0, timeMarkIndex: nil)
                ),
                .init(
                    index: 7,
                    timeRange: (10..<10)
                ),
            ]
        )
    }
    
    func test_parse__with_no_space_between_time_marks() async throws {
        
        let subtitles = Subtitles(duration: 10, sentences: [
            .anySentence(at: 0, timeMarks: [
                .anyTimeMark(at: 1, duration: 1),
                .anyTimeMark(at: 2, duration: 1),
            ]),
        ])
        
        AssertEqualReadable(
            createSUT().parse(from: subtitles),
            [
                .init(
                    index: 0,
                    timeRange: (0..<1),
                    subtitlesPosition: .init(sentenceIndex: 0, timeMarkIndex: nil)
                ),
                .init(
                    index: 1,
                    timeRange: (1..<2),
                    subtitlesPosition: .init(sentenceIndex: 0, timeMarkIndex: 0)
                ),
                .init(
                    index: 2,
                    timeRange: (2..<3),
                    subtitlesPosition: .init(sentenceIndex: 0, timeMarkIndex: 1)
                ),
                .init(
                    index: 3,
                    timeRange: (3..<10),
                    subtitlesPosition: .init(sentenceIndex: 0, timeMarkIndex: nil)
                ),
                .init(
                    index: 4,
                    timeRange: (10..<10)
                ),
            ]
        )
    }

}

