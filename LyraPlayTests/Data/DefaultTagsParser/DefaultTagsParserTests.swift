//
//  DefaultTagsParserTests.swift
//  LyraPlayTests
//
//  Created by Azat Kaiumov on 22.06.22.
//

import XCTest
@testable import LyraPlay

class DefatulTagsParserTests: XCTestCase {
    
    var tagsParser: TagsParser!
    
    override func setUpWithError() throws {
        tagsParser = DefaultTagsParser()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testParse() async {
        
        let bundle = Bundle(for: type(of: self ))
        
        let url = bundle.url(forResource: "test_music_with_tags", withExtension: "mp3")!
        
        let testFileWithId3 = try! Data(contentsOf: url)
        XCTAssertNotNil(testFileWithId3)
        
        let result = await tagsParser.parse(data: testFileWithId3)
        let tags = AssertResultSucceded(result)
        
        guard let tags = tags else {
            XCTAssertNotNil(tags)
            return
        }
        
        XCTAssertEqual(tags.artist ?? "", "Test Artist")
        XCTAssertEqual(tags.title ?? "", "Test Title")
        XCTAssertEqual(tags.genre ?? "", "Test Genre")
        XCTAssertNotNil(tags.coverImage)
        XCTAssertNotNil(tags.coverImageExtension, "png")
        XCTAssertNotNil(tags.lyrics)
        XCTAssertTrue(tags.lyrics?.contains("length: 0:19") ?? false)
    }
}
