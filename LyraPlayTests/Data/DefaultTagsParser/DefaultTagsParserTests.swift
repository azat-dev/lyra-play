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

        switch result {
        case .failure:
            XCTAssertFalse(true, "Can't parse id3 tags")
            
        case .success(let tags):
            
            XCTAssertEqual(tags.artist ?? "", "Test Artist")
            XCTAssertEqual(tags.title ?? "", "Test Title")
            XCTAssertEqual(tags.genre ?? "", "Test Genre")
            XCTAssertNotNil(tags.coverImage)
            XCTAssertNotNil(tags.lyrics)
            XCTAssertTrue(tags.lyrics?.contains("length: 0:19") ?? false)
        }
    }
}
