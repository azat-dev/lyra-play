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
    private var audioLibraryRepository: AudioLibraryRepository!
    private var playerStateRepository: PlayerStateRepository!
    private var audioFilesRepository: FilesRepository!
    private var imagesRepository: FilesRepositoryMock!
    
//    private var progressDelegate: AudioPlayerProgressDelegate?

    override func setUp() async throws {
        
        let keyValueStore = UserDefaultsKeyValueStore(storeName: "test")
        playerStateRepository = DefaultPlayerStateRepository(keyValueStore: keyValueStore, key: "player-state")
        audioLibraryRepository = AudioFilesRepositoryMock()
        audioFilesRepository = FilesRepositoryMock()
        imagesRepository = FilesRepositoryMock()
        
        useCase = DefaultAudioPlayerUseCase(
            audioLibraryRepository: audioLibraryRepository,
            audioFilesRepository: audioFilesRepository,
            imagesRepository: imagesRepository,
            playerStateRepository: playerStateRepository,
            audioPlayerService: DefaultAudioPlayerService()
        )
    }
    
    func setUpTestTracks() async throws {
        
        let bundle = Bundle(for: type(of: self ))
        let url = bundle.url(forResource: "test_music_with_tags", withExtension: "mp3")!
        let data = try? Data(contentsOf: url)
        
        let testTrackData = try! XCTUnwrap(data)
        
        let numberOfTracks = 3
        
        for index in 0..<numberOfTracks {
            
            let result = await audioLibraryRepository.putFile(
                info: AudioFileInfo.create(name: "Track \(index)", duration: 10, audioFile: "test.mp3"),
                data: testTrackData
            )
            try AssertResultSucceded(result)
        }
    }

    func testSetTrack() async throws {

        try await setUpTestTracks()
        
        let resultFiles = await audioLibraryRepository.listFiles()
        let files = try AssertResultSucceded(resultFiles)
        
        let testFileId = try! XCTUnwrap(files.first?.id)
        
        let setTrackResult = await useCase.setTrack(fileId: testFileId)
        try AssertResultSucceded(setTrackResult)
        
        let currentTrackResult = await useCase.getCurrentTrackId()
        let currentTrackId = try AssertResultSucceded(currentTrackResult)
        
        XCTAssertEqual(currentTrackId, testFileId)
    }
    
    func testSetTrackDoesntExist() async {

        let testFileId = UUID()

        let setTrackResult = await useCase.setTrack(fileId: testFileId)
        AssertResultFailed(setTrackResult)
    }

    func testPlay() async throws {

        try await setUpTestTracks()
        
        let resultFiles = await audioLibraryRepository.listFiles()
        let files = try AssertResultSucceded(resultFiles)
        
        let testFileId = try! XCTUnwrap(files.first?.id)
        
        let setTrackResult = await useCase.setTrack(fileId: testFileId)
        try AssertResultSucceded(setTrackResult)

        let resultPlay = await useCase.play()
        try AssertResultSucceded(resultPlay)
        
        let playingExpectation = expectation(description: "Playing")
        
        useCase.isPlaying.observe(on: self) { isPlaying in
            if isPlaying {
                playingExpectation.fulfill()
            }
        }
        
        wait(for: [playingExpectation], timeout: 10, enforceOrder: false)
    }
    
//    func testPlayRemovedTrack() async {
//
//        await setUpTestTracks()
//        
//        let resultFiles = await audioLibraryRepository.listFiles()
//        let files = try AssertResultSucceded(resultFiles)
//        
//        let testFileId = try! XCTUnwrap(files.first?.id)
//        
//        let setTrackResult = await useCase.setTrack(fileId: testFileId)
//        try AssertResultSucceded(setTrackResult)
//
//        for file in files {
//            await audioLibraryRepository.delete(fileId: file.id!)
//        }
//        
//        let resultPlay = await useCase.play()
//        AssertResultFailed(resultPlay)
//    }
//
//    func testPause() async {
//        
//        await setUpTestTracks()
//        
//        let resultFiles = await audioLibraryRepository.listFiles()
//        let files = try AssertResultSucceded(resultFiles)
//        
//        let testFileId = try! XCTUnwrap(files.first?.id)
//        
//        let setTrackResult = await useCase.setTrack(fileId: testFileId)
//        try AssertResultSucceded(setTrackResult)
//
//        let resultPlay = await useCase.play()
//        try AssertResultSucceded(resultPlay)
//        
//        sleep(10)
//        let resultPause = await useCase.pause()
//        try AssertResultSucceded(resultPause)
//    }
//
//    func testVolumeUp() {
//
//        let result = await useCase.pause()
//        try AssertResultSucceded(result)
//    }
//
//    func testVolumeDown() {
//
//        let result = await useCase.pause()
//        try AssertResultSucceded(result)
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
//        let filesResult = audioLibraryRepository.listFiles()
//        let files = try AssertResultSucceded(filesResult)
//
//        let firstFile = XCTUnwrap(files.first)
//        let firstFileId = XCTUnwrap(firstFile.id)
//
//        let loadResult = await useCase.loadTrack(fileId: firstFileId)
//        try AssertResultSucceded(loadResult)
//
//    }
//
//    func testSetTrackTime() async {
//
//    }
}
