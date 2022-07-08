//
//  DefaultTagsParserTests.swift
//  LyraPlayTests
//
//  Created by Azat Kaiumov on 22.06.22.
//

import XCTest
@testable import LyraPlay

class DefatulTagsParserTests: XCTestCase {
    
    func createSUT() -> TagsParser {
        
        let tagsParser = DefaultTagsParser()
        detectMemoryLeak(instance: tagsParser)
        
        return tagsParser
    }

    func testParse() async throws {
        
        let tagsParser = createSUT()
        
        let bundle = Bundle(for: type(of: self ))
        let url = bundle.url(forResource: "test_music_with_tags", withExtension: "mp3")!
        
        let result = await tagsParser.parse(url: url)
        let tags = try AssertResultSucceded(result)
        
        XCTAssertEqual(tags.artist ?? "", "Test Artist")
        XCTAssertEqual(tags.title ?? "", "Test Title")
        XCTAssertEqual(tags.genre ?? "", "Test Genre")
        XCTAssertNotNil(tags.coverImage?.data)
        XCTAssertNotNil(tags.coverImage?.fileExtension, "png")
        XCTAssertNotNil(tags.lyrics)
        XCTAssertTrue(tags.lyrics?.contains("length: 0:19") ?? false)
        XCTAssertEqual(tags.duration, 19.0, accuracy: 1.0)
    }
}
