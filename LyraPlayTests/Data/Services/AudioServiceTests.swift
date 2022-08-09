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

    func createSUT() -> AudioService {

        let audioService = DefaultAudioService()
        detectMemoryLeak(instance: audioService)
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
}
