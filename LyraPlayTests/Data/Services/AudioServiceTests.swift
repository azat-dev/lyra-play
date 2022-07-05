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
    
    private func getTestFile() throws -> Data {
        
        let bundle = Bundle(for: type(of: self ))
        let url = bundle.url(forResource: "test_music_with_tags", withExtension: "mp3")!
        
        return try Data(contentsOf: url)
    }
    
    func testPlay() async throws {
        
        let audioService = createSUT()
    
        let fileId1 = "test1"
        let fileId2 = "test2"
        
        let playingSequence = AssertSequence(testCase: self, values: [false, true, true])
        let filesIdsSequence = AssertSequence(testCase: self, values: [nil, fileId1, fileId2])
        
        playingSequence.observe(audioService.isPlaying)
        filesIdsSequence.observe(audioService.fileId)
        
        let data = try getTestFile()
        
        let result1 = await audioService.play(fileId: fileId1, data: data)
        try AssertResultSucceded(result1)
        
        sleep(1)
        
        let result2 = await audioService.play(fileId: fileId2, data: data)
        try AssertResultSucceded(result2)
        
        sleep(1)
        
        playingSequence.wait(timeout: 5, enforceOrder: true)
        filesIdsSequence.wait(timeout: 5, enforceOrder: true)
    }
}
