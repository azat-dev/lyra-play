//
//  SubtitlesParserImplTests.swift
//  LyraPlayTests
//
//  Created by Azat Kaiumov on 20.08.22.
//

import Foundation
import XCTest
import LyraPlay
import Mockingbird

class SubtitlesParserImplTests: XCTestCase {

    typealias SUT = (
        parser: SubtitlesParser,
        textSplitter: TextSplitterMock
    )
    
    func createSUT(parsers: [SubtitlesParserImpl.FileExtension: SubtitlesParserFactory]) -> SUT {
        
        let textSplitter = TextSplitterMock()
        let parser = SubtitlesParserImpl(parsers: parsers)
        
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
    
    private func anySubtitles() -> Subtitles {
        
        return .init(duration: 0, sentences: [])
    }
    
    func test_parse__select_parser_by_extension() async throws {
        
        // Given not empty file
        
        let text = ""
        
        let parser1Factory = mock(SubtitlesParserFactory.self)
        let parser1 = mock(SubtitlesParser.self)
        
        given(parser1Factory.make())
            .willReturn(parser1)
        
        given(await parser1.parse(any(), fileName: any()))
            .willReturn(.success(anySubtitles()))
        
        let parser2Factory = mock(SubtitlesParserFactory.self)
        
        let parser2 = mock(SubtitlesParser.self)
        
        given(parser2Factory.make())
            .willReturn(parser2)
        
        given(await parser2.parse(any(), fileName: any()))
            .willReturn(.failure(.internalError(nil)))
        
        let sut = createSUT(parsers: [
            ".test1": parser1Factory,
            ".test2": parser2Factory,
        ])

        // When
        let result = await sut.parser.parse(text, fileName: "filename.test1")
        
        // Then
        try AssertResultSucceded(result)
    }
}
