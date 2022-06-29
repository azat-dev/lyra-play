//
//  AudioPlayerUseCaseTests.swift
//  LyraPlayTests
//
//  Created by Azat Kaiumov on 28.06.22.
//

import Foundation

import XCTest
import LyraPlay

class AudioPlayerUseCaseTests: XCTestCase {

    private var useCase: AudioPlayerUseCase!
    private var audioFilesRepository: AudioFilesRepository!
    private var playerStateRepository: PlayerStateRepository!
    
//    private var progressDelegate: AudioPlayerProgressDelegate?

    override func setUp() async throws {
        
        let keyValueStore = UserDefaultsKeyValueStore(storeName: "test")
        playerStateRepository = DefaultPlayerStateRepository(keyValueStore: keyValueStore, key: "player-state")
        audioFilesRepository = AudioFilesRepositoryMock()
        
        useCase = DefaultAudioPlayerUseCase(
            audioFilesRepository: audioFilesRepository,
            playerStateRepository: playerStateRepository
        )
    }
    
    func setUpTestTracks() async {
        
        let bundle = Bundle(for: type(of: self ))
        let url = bundle.url(forResource: "test_music_with_tags", withExtension: "mp3")!
        let data = try? Data(contentsOf: url)
        
        let testTrackData = try! XCTUnwrap(data)
        
        let numberOfTracks = 3
        
        for index in 0..<numberOfTracks {
            
            let result = await audioFilesRepository.putFile(
                info: AudioFileInfo.create(name: "Track \(index)"),
                data: testTrackData
            )
            AssertResultSucceded(result)
        }
    }

    func testSetTrack() async {

        await setUpTestTracks()
        
        let resultFiles = await audioFilesRepository.listFiles()
        let files = AssertResultSucceded(resultFiles)
        
        let testFileId = try! XCTUnwrap(files.first?.id)
        
        let setTrackResult = await useCase.setTrack(fileId: testFileId)
        AssertResultSucceded(setTrackResult)
        
        let currentTrackResult = await useCase.getCurrentTrackId()
        let currentTrackId = AssertResultSucceded(currentTrackResult)
        
        XCTAssertEqual(currentTrackId, testFileId)
    }
    
    func testSetTrackDoesntExist() async {

        let testFileId = UUID()

        let setTrackResult = await useCase.setTrack(fileId: testFileId)
        AssertResultFailed(setTrackResult)
    }

    func testPlay() async {

        await setUpTestTracks()
        
        let resultFiles = await audioFilesRepository.listFiles()
        let files = AssertResultSucceded(resultFiles)
        
        let testFileId = try! XCTUnwrap(files.first?.id)
        
        let setTrackResult = await useCase.setTrack(fileId: testFileId)
        AssertResultSucceded(setTrackResult)

        let resultPlay = await useCase.play()
        AssertResultSucceded(resultPlay)
    }
    
    func testPlayRemovedTrack() async {

        await setUpTestTracks()
        
        let resultFiles = await audioFilesRepository.listFiles()
        let files = AssertResultSucceded(resultFiles)
        
        let testFileId = try! XCTUnwrap(files.first?.id)
        
        let setTrackResult = await useCase.setTrack(fileId: testFileId)
        AssertResultSucceded(setTrackResult)

        for file in files {
            await audioFilesRepository.delete(fileId: file.id)
        }
        
        let resultPlay = await useCase.play()
        AssertResultFailed(resultPlay)
    }

    func testPause() {
        
        await setUpTestTracks()
        
        let resultFiles = await audioFilesRepository.listFiles()
        let files = AssertResultSucceded(resultFiles)
        
        let testFileId = try! XCTUnwrap(files.first?.id)
        
        let setTrackResult = await useCase.setTrack(fileId: testFileId)
        AssertResultSucceded(setTrackResult)

        let resultPlay = await useCase.play()
        AssertResultSucceded(resultPlay)
        
        sleep(10)
        let resultPause = await useCase.pause()
        AssertResultSucceded(resultPause)
    }
//
//    func testVolumeUp() {
//
//        let result = await useCase.pause()
//        AssertResultSucceded(result)
//    }
//
//    func testVolumeDown() {
//
//        let result = await useCase.pause()
//        AssertResultSucceded(result)
//    }
//
//    func testProgregssDelegate() {
//
//    }
//

//
//    func testPlayNextTrack() async {
//
//    }
//
//    func testPlayPreviousTrack() async {
//
//    }
//
//    func testPlayNextTrackAfterCurrent() async {
//
//    }
//
//    func testRememberLastTrack() async {
//
//        await setUpTestTracks()
//
//        let filesResult = audioFilesRepository.listFiles()
//        let files = AssertResultSucceded(filesResult)
//
//        let firstFile = XCTUnwrap(files.first)
//        let firstFileId = XCTUnwrap(firstFile.id)
//
//        let loadResult = await useCase.loadTrack(fileId: firstFileId)
//        AssertResultSucceded(loadResult)
//
//    }
//
//    func testSetTrackTime() async {
//
//    }
}
