//
//  DefaultSubtitlesParserTests.swift
//  LyraPlayTests
//
//  Created by Azat Kaiumov on 20.08.22.
//

import Foundation
import XCTest
import LyraPlay

class DefaultSubtitlesParserTests: XCTestCase {

    typealias SUT = (
        parser: SubtitlesParser,
        textSplitter: TextSplitterMock
    )
    
    func createSUT(parsers: [DefaultSubtitlesParser.FileExtension: SubtitlesParser]) -> SUT {
        
        let textSplitter = TextSplitterMock()
        let parser = DefaultSubtitlesParser(parsers: parsers)
        detectMemoryLeak(instance: parser)
        
        return (
            parser,
            textSplitter
        )
    }
    
    func test_parse__no_parsers() async throws {
        
        // Given
        // Empty text
        let sut = createSUT(parsers: [:])
        let text = ""

        // When
        let result = await sut.parser.parse(text, fileName: "subtitles.test")
        let error = try AssertResultFailed(result)
        
        guard case .internalError = error else {
            
            XCTFail("Wrong error type \(error)")
            return
        }
    }
    
    func test_parse__select_parser_by_extension() async throws {
        
        // Given not empty file
        
        let text = ""
        
        let parser1 = SubtitlesParserMock()
        parser1.resolve = { _, _ in .success(.init(duration: 0, sentences: [])) }
        
        let parser2 = SubtitlesParserMock()
        parser2.resolve = { _, _ in .failure(.internalError(nil))}
        
        let sut = createSUT(parsers: [
            ".test1": parser1,
            ".test2": parser2,
        ])

        // When
        let result = await sut.parser.parse(text, fileName: "filename.test1")
        
        // Then
        try AssertResultSucceded(result)
    }
}
