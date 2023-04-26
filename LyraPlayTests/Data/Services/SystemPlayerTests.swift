//
//  SystemPlayerTests.swift
//  LyraPlayTests
//
//  Created by Azat Kaiumov on 26.04.23.
//

import Foundation
import XCTest
import LyraPlay

class SystemPlayerTests: XCTestCase {
    
    typealias SUT = SystemPlayer
    
    func createSUT() throws -> SUT {
        
        let shortData = try getTestFile(name: "test_music_with_tags_short")
        
        let data: Data
        let player = try SystemPlayerImpl(data: shortData)
        
        return player
    }
    
    func test_duration() async throws {
        
        // Given
        let sut = try createSUT()
        
        // When
        // Loaded
        
        // Then
        XCTAssertGreaterThan(sut.duration, 0)
    }
    
    func test_currentTime__get() async throws {
        
        // Given
        let sut = try createSUT()
        
        // When
        // Loaded
        
        // Then
        XCTAssertEqual(sut.currentTime, 0)
    }
    
    func test_currentTime__set() async throws {
        
        // Given
        let sut = try createSUT()

        let duration = sut.duration
        let newTime = duration - 0.01
        
        // When
        sut.currentTime = newTime

        // Then
        let diff = abs(sut.currentTime - newTime)
        XCTAssertLessThan(diff, 0.001)
    }
    
    private func getTestFile(name: String = "test_music_with_tags") throws -> Data {

        let bundle = Bundle(for: type(of: self ))
        let url = bundle.url(forResource: name, withExtension: "mp3")!

        return try Data(contentsOf: url)
    }
}
