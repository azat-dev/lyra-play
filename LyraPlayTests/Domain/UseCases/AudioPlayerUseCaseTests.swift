////
////  AudioPlayerUseCaseTests.swift
////  LyraPlayTests
////
////  Created by Azat Kaiumov on 28.06.22.
////
//
//import Foundation
//
//import XCTest
//import LyraPlay
//
//class AudioPlayerUseCaseTests: XCTestCase {
//
//    private var useCase: AudioPlayerUseCaseTests!
//    private var audioFilesRepository: AudioFilesRepository!
//    private var playerStateRepository: PlayerStateRepository!
//    
////    private var progressDelegate: AudioPlayerProgressDelegate?
//
//    override func setUp() async throws {
//        
//        currentPlayStateRepository = DefaultCurrentPlayStateRepository()
//        audioFilesRepository = AudioFilesRepositoryMock()
//        
//        useCase = DefaultAudioPlayerUseCase(
//            audioFilesRepository: audioFilesRepository,
//            playerStateRepository: playerStateRepository
//        )
//    }
//    
//    func setUpTestTracks() async {
//        
//        let bundle = Bundle(for: type(of: self ))
//        let url = bundle.url(forResource: "test_music_with_tags", withExtension: "mp3")!
//        let data = try? Data(contentsOf: url)
//        
//        let testTrackData = try! XCTUnwrap(data)
//        
//        let numberOfTracks = 3
//        
//        for index in 0..<numberOfTracks {
//            
//            let result = await audioFilesRepository.putFile(
//                info: AudioFileInfo.create(name: "Track \(index)"),
//                data: testTrackData
//            )
//            AssertResultSucceded(result)
//        }
//    }
//
//    func testSetTrack() async {
//
//        await setUpTestTracks()
//        
//        let resultFiles = await audioFilesRepository.listFiles()
//        let files = AssertResultSucceded(resultFiles)
//        
//        let testFileId = try! XCTUnwrap(files.first?.id)
//        
//        let setTrackResult = await useCase.setTrack(fileId: testFileId)
//        AssertResultSucceded(setTrackResult)
//        
//        let currentTrackResult = await useCase.getCurrentTrack()
//        let currentTrackId = AssertResultSucceded(resultSetTrack)
//        
//        XCTAssertEqual(currentTrackId, testFileId)
//    }
//    
////    func testSetTrackDoesntExist() {
////
////        let testFileId = UUID()
////
////        let setTrackResult = await useCase.setTrack(fileId: testFileId)
////        AssertResultSucceded(setTrackResult)
////
////        let currentTrackResult = await useCase.getCurrentTrack()
////        let currentTrackId = AssertResultSucceded(setTrackResult)
////
////        XCTAssertEqual(currentTrackId, testFileId)
////    }
////
////    func testPlay() {
////
////        let testFileId = ""
////
////        let setTrackResult = await useCase.setTrack(fileId: testFileId)
////        AssertResultSucceded(setTrackResult)
////
////        let resultPlay = await useCase.play()
////        AssertResultSucceded(result)
////    }
////
////    func testPause() {
////    }
////
////    func testVolumeUp() {
////
////        let result = await useCase.pause()
////        AssertResultSucceded(result)
////    }
////
////    func testVolumeDown() {
////
////        let result = await useCase.pause()
////        AssertResultSucceded(result)
////    }
////
////    func testProgregssDelegate() {
////
////    }
////
//
////
////    func testPlayNextTrack() async {
////
////    }
////
////    func testPlayPreviousTrack() async {
////
////    }
////
////    func testPlayNextTrackAfterCurrent() async {
////
////    }
////
////    func testRememberLastTrack() async {
////
////        await setUpTestTracks()
////
////        let filesResult = audioFilesRepository.listFiles()
////        let files = AssertResultSucceded(filesResult)
////
////        let firstFile = XCTUnwrap(files.first)
////        let firstFileId = XCTUnwrap(firstFile.id)
////
////        let loadResult = await useCase.loadTrack(fileId: firstFileId)
////        AssertResultSucceded(loadResult)
////
////    }
////
////    func testSetTrackTime() async {
////
////    }
//}
