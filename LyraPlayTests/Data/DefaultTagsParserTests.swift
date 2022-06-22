//
//  DefaultTagsParserTests.swift
//  LyraPlayTests
//
//  Created by Azat Kaiumov on 22.06.22.
//

import XCTest

class DefatulTagsParserTests: XCTestCase {
    
    var tagsParser: TagsParser
    
    override func setUpWithError() throws {
        tagsParser = DefaultTagsParser()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        let testFileUrl = Bundle.main.url(forResource: "test", withExtension: "mp3")!
        let testFileWithId3 = try! Data(contentsOf: testFileUrl)
        
        let result: Result = await tagsParser.parse(data: testFileWithId3)
        
        switch result {
        case .failure:
            XCTAssertFalse(true)
        case .success(let tags):
            XCTAssertEqual(tags.artist, "Test Artist")
            XCTAssertEqual(tags.title, "Test Title")
            XCTAssertNotNil(tags.image)
            XCTAssertEqual(tags.lyrics, "Test lyrics")
        }
    }
}
