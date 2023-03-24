//
//  AudioPlayerTests.swift
//  LyraPlayTests
//
//  Created by Azat Kaiumov on 05.07.22.
//

import Foundation

import XCTest
import LyraPlay

class AudioPlayerTests: XCTestCase {

    func createSUT(file: StaticString = #filePath, line: UInt = #line) -> AudioPlayer {

        let audioPlayer = AudioPlayerImpl()
        
        detectMemoryLeak(instance: audioPlayer, file: file, line: line)
        return audioPlayer
    }
    
    private func getTestFile(name: String = "test_music_with_tags") throws -> Data {
        
        let bundle = Bundle(for: type(of: self ))
        let url = bundle.url(forResource: name, withExtension: "mp3")!
        
        return try Data(contentsOf: url)
    }
    
    func test_play() async throws {
        
        let audioPlayer = createSUT()
        
        let stateObserver = watch(audioPlayer.state)
    
        // Given
        let fileId1 = "test1"
        let fileId2 = "test2"
        
        let session1 = AudioPlayerSession(fileId: fileId1)
        let session2 = AudioPlayerSession(fileId: fileId2)
        
        let data = try getTestFile()
        let shortData = try getTestFile(name: "test_music_with_tags_short")

        // When
        let prepareResult1 = audioPlayer.prepare(fileId: fileId1, data: data)
        
        // Then
        try AssertResultSucceded(prepareResult1)
        
        // When
        let result1 = audioPlayer.play(atTime: 0)
        
        // Then
        try AssertResultSucceded(result1)
        
        sleep(1)
        
        let prepareResult2 = audioPlayer.prepare(fileId: fileId2, data: shortData)
        try AssertResultSucceded(prepareResult2)
        
        let result2 = audioPlayer.play(atTime: 0)
        try AssertResultSucceded(result2)
        
        sleep(1)
        
        stateObserver.expect([
        
            AudioPlayerState.initial,
            .loaded(session: session1),
            .playing(session: session1),
            .initial,
            .loaded(session: session2),
            .playing(session: session2),
            .finished(session: session2)
        ], timeout: 5)
    }
    
    func test_playAndWaitForEnd__success() async throws {
        
        let audioPlayer = createSUT()
        let stateObserver = watch(audioPlayer.state)
        
        // Given
        
        let fileId1 = "test1"
        let fileId2 = "test2"
        
        let session1 = AudioPlayerSession(fileId: fileId1)
        let session2 = AudioPlayerSession(fileId: fileId2)
        
        let shortData = try getTestFile(name: "test_music_with_tags_short")
        
        let prepareResult1 = audioPlayer.prepare(fileId: fileId1, data: shortData)
        try AssertResultSucceded(prepareResult1)

        // When
        let result = await audioPlayer.playAndWaitForEnd()
        
        // Then
        try AssertResultSucceded(result)
        XCTAssertEqual(audioPlayer.state.value, .finished(session: .init(fileId: fileId1)))
        
        let prepareResult2 = audioPlayer.prepare(fileId: fileId2, data: shortData)
        try AssertResultSucceded(prepareResult2)

        // When
        let result2 = await audioPlayer.playAndWaitForEnd()
        
        // Then
        try AssertResultSucceded(result2)
        XCTAssertEqual(audioPlayer.state.value, .finished(session: .init(fileId: fileId2)))
        
        stateObserver.expect([
            AudioPlayerState.initial,
            .loaded(session: session1),
            .playing(session: session1),
            .finished(session: session1),
            .initial,
            .loaded(session: session2),
            .playing(session: session2),
            .finished(session: session2)
        ])
    }
    
    func test_playAndWaitForEnd__stop() async throws {
        
        let audioPlayer = createSUT()
    
        // Given
        let fileId = "test1"
        
        let shortData = try getTestFile(name: "test_music_with_tags_short")

        let observer = audioPlayer.state.sink { [weak audioPlayer] state in

            guard let audioPlayer = audioPlayer else {
                return
            }
            
            if case .playing = state {
                let _ = audioPlayer.stop()
            }
        }
        
        let _ = audioPlayer.prepare(fileId: fileId, data: shortData)
        
        // When
        let result = await audioPlayer.playAndWaitForEnd()
        
        // Then
        let error = try AssertResultFailed(result)

        guard case .waitIsInterrupted = error else {
            
            XCTFail("Wrong error type \(error)")
            return
        }
        
        observer.cancel()
    }
    
    func test_play__stream() async throws {
        
        let audioPlayer = createSUT()
    
        // Given
        
        let fileId1 = "test1"
        let fileId2 = "test2"
        
        let session1 = AudioPlayerSession(fileId: fileId1)
        let session2 = AudioPlayerSession(fileId: fileId2)
        
        let stateObserver = watch(audioPlayer.state)
        
        let iteratedStateSequence = self.expectSequence([
            AudioPlayerState.playing(session: session1),
            .finished(session: session1),
            .playing(session: session2),
            .finished(session: session2)
        ])
        
        let shortData = try getTestFile(name: "test_music_with_tags_short")
        
        let prepareResult1 = audioPlayer.prepare(fileId: fileId1, data: shortData)
        try AssertResultSucceded(prepareResult1)
        
        do {
        
            for try await state in audioPlayer.playAndWaitForEnd() {
                iteratedStateSequence.fulfill(with: state)
            }
            
        } catch {
            
            XCTFail("Throw an error")
        }
        
        let prepareResult2 = audioPlayer.prepare(fileId: fileId2, data: shortData)
        try AssertResultSucceded(prepareResult2)
        
        do {
        
            for try await state in audioPlayer.playAndWaitForEnd() {
                iteratedStateSequence.fulfill(with: state)
            }
            
        } catch {
            
            XCTFail("Throw an error")
        }

        iteratedStateSequence.wait(timeout: 0, enforceOrder: true)
        
        stateObserver.expect([
            AudioPlayerState.initial,
            .loaded(session: session1),
            .playing(session: session1),
            .finished(session: session1),
            .initial,
            .loaded(session: session2),
            .playing(session: session2),
            .finished(session: session2)
        ])
    }
}
