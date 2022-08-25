//
//  PlayerViewControllerTests.swift
//  LyraPlayTests
//
//  Created by Azat Kaiumov on 01.07.22.
//

import Foundation
import LyraPlay
import XCTest


class PlayerViewModelTests: XCTestCase {

//    private var playMediaUseCase: PlayMediaUseCase!
//    private var playerViewModel: PlayerViewModel!
//    
//    override func setUp() async throws {
//        
//        playMediaUseCase = PlayMediaUseCaseMock()
//        playerViewModel = PlayerViewModelImpl(playMediaUseCase: playMediaUseCase)
//    }
//    
//
//    func testLoadTrack() async {
//    
//        let trackInfoLoading = expectation(description: "Track info is loading")
//        let trackInfoLoaded = expectation(description: "Track info is loaded")
//        
//        playerViewModel.trackInfo.observe(on: self) { trackInfo in
//            
//            if trackInfo == nil {
//                trackInfoLoading.fulfill()
//            } else {
//                trackInfoLoaded.fulfill()
//            }
//        }
//        
//        await playerViewModel.load()
//        
//        wait(for: [trackInfoLoading, trackInfoLoaded], timeout: 10, enforceOrder: true)
//    }
//    
//    func testTogglePlay() async {
//        
//        let notPlayingExpectation = expectation(description: "Not playing")
//        let playingExpectation = expectation(description: "Playing")
//        
//        playerViewModel.isPlaying.observe(on: self) { isPlaying in
//            if isPlaying {
//                playingExpectation.fulfill()
//            } else {
//                notPlayingExpectation.fulfill()
//            }
//        }
//        
//        await playerViewModel.togglePlay()
//        
//        wait(for: [notPlayingExpectation, playingExpectation], timeout: 3, enforceOrder: true)
//        
//    }
//    
//    func testPlay() async {
//        
//        await playerViewModel.togglePlay()
//        
//        let playingExpectation = expectation(description: "Playing")
//        let currentTimeExpectation = expectation(description: "Current time is changed")
//        let progressExpectation = expectation(description: "Progress is changed")
//        
//        playerViewModel.currentTime.observe(on: self) { newTime in
//            if !newTime.isEmpty {
//                currentTimeExpectation.fulfill()
//            }
//        }
//
//        playerViewModel.progress.observe(on: self) { progress in
//            if progress > 0 {
//                progressExpectation.fulfill()
//            }
//        }
//        
//        playerViewModel.isPlaying.observe(on: self) { isPlaying in
//            if isPlaying {
//                playingExpectation.fulfill()
//            }
//        }
//
//        let expectations = [
//            currentTimeExpectation,
//            playingExpectation,
//            progressExpectation
//        ]
//        wait(for: expectations, timeout: 3, enforceOrder: false)
//    }
//    
//    func testPause() async {
//        
//        await playerViewModel.togglePlay()
//        await playerViewModel.togglePlay()
//        
//        let currentTimeExpectation = expectation(description: "Current time is changed")
//        currentTimeExpectation.isInverted = true
//        
//        let progressExpectation = expectation(description: "Progress time is changed")
//        progressExpectation.isInverted = true
//        
//        playerViewModel.currentTime.observe(on: self) { _ in
//            currentTimeExpectation.fulfill()
//        }
//
//        playerViewModel.progress.observe(on: self) { _ in
//            progressExpectation.fulfill()
//        }
//
//        wait(for: [currentTimeExpectation, progressExpectation], timeout: 3, enforceOrder: false)
//    }
}
