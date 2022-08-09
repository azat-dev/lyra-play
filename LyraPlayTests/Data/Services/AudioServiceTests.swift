//
//  AudioServiceTests.swift
//  LyraPlayTests
//
//  Created by Azat Kaiumov on 05.07.22.
//

import Foundation

import XCTest
import LyraPlay

class AudioServiceTests: XCTestCase {

    func createSUT(file: StaticString = #filePath, line: UInt = #line) -> AudioService {

        let audioService = DefaultAudioService()
        detectMemoryLeak(instance: audioService, file: file, line: line)
        return audioService
    }
    
    private func getTestFile(name: String = "test_music_with_tags") throws -> Data {
        
        let bundle = Bundle(for: type(of: self ))
        let url = bundle.url(forResource: name, withExtension: "mp3")!
        
        return try Data(contentsOf: url)
    }
    
    func test_play() async throws {
        
        let audioService = createSUT()
    
        let fileId1 = "test1"
        let fileId2 = "test2"
        
        let stateSequence = self.expectSequence([
            AudioServiceState.initial,
            .playing(data: .init(fileId: fileId1)),
            .playing(data: .init(fileId: fileId2)),
            .finished(data: .init(fileId: fileId2))
        ])
        
        stateSequence.observe(audioService.state)
        
        let data = try getTestFile()
        let shortData = try getTestFile(name: "test_music_with_tags_short")
        
        let result1 = await audioService.play(fileId: fileId1, data: data)
        try AssertResultSucceded(result1)
        
        sleep(1)
        
        let result2 = await audioService.play(fileId: fileId2, data: shortData)
        try AssertResultSucceded(result2)
        
        sleep(1)
        
        stateSequence.wait(timeout: 5, enforceOrder: true)
    }
    
    func test_playAndWaitForEnd__success() async throws {
        
        let audioService = createSUT()
    
        let fileId1 = "test1"
        let fileId2 = "test2"
        
        let stateSequence = self.expectSequence([
            AudioServiceState.initial,
            .playing(data: .init(fileId: fileId1)),
            .finished(data: .init(fileId: fileId1)),
            .playing(data: .init(fileId: fileId2)),
            .finished(data: .init(fileId: fileId2))
        ])
        
        stateSequence.observe(audioService.state)
        
        let shortData = try getTestFile(name: "test_music_with_tags_short")
        
        let result = await audioService.playAndWaitForEnd(fileId: fileId1, data: shortData)
        
        try AssertResultSucceded(result)
        XCTAssertEqual(audioService.state.value, .finished(data: .init(fileId: fileId1)))
        
        let result2 = await audioService.playAndWaitForEnd(fileId: fileId2, data: shortData)
        
        try AssertResultSucceded(result2)
        XCTAssertEqual(audioService.state.value, .finished(data: .init(fileId: fileId2)))
        
        stateSequence.wait(timeout: 0, enforceOrder: true)
    }
    
    func test_playAndWaitForEnd__interrupted() async throws {
        
        let audioService = createSUT()
    
        let fileId = "test1"
        
        let shortData = try getTestFile(name: "test_music_with_tags_short")

        audioService.state.observe(on: self) { [weak audioService] state in

            guard let audioService = audioService else {
                return
            }
            
            if case .playing = state {

                Task {
                    await audioService.stop()
                }
            }
        }
        
        let result = await audioService.playAndWaitForEnd(fileId: fileId, data: shortData)
        let error = try AssertResultFailed(result)

        guard case .waitIsInterrupted = error else {
            
            XCTFail("Wrong error type \(error)")
            return
        }
        
        audioService.state.remove(observer: self)
    }
}
