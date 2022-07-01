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

    private var audioPlayerUseCase: AudioPlayerUseCase!
    private var playerViewModel: PlayerViewModel!
    
    override func setUp() async throws {
        
        audioPlayerUseCase = AudioPlayerUseCaseMock()
        playerViewModel = DefaultPlayerViewModel(audioPlayerUseCase: audioPlayerUseCase)
    }
    

    func testLoadTrack() {
    
        let loadingExpectation = expectation(description: "Loading")
        let loadedExpectation = expectation(description: "Loaded")
        
        let trackInfoLoading = expectation(description: "Track info is loading")
        let trackInfoLoaded = expectation(description: "Track info is loaded")
        
        playerViewModel.trackInfo.observe(on: self) { trackInfo in
            
            if trackInfo == nil {
                trackInfoLoading.fulfill()
            } else {
                trackInfoLoaded.fulfill()
            }
        }
        
        
        playerViewModel.load()
        
        wait(for: [trackInfoLoading, trackInfoLoaded], timeout: 10, enforceOrder: true)
    }
    
    func testPlay() {
        
        playerViewModel.togglePlay()
        
        let playingExpectation = expectation(description: "Playing")
        let currentTimeExpectation = expectation(description: "Current time is changed")
        let progressExpectation = expectation(description: "Progress is changed")
        
        playerViewModel.currentTime.observe(on: self) { newTime in
            currentTimeExpectation.fulfill()
        }

        playerViewModel.progress.observe(on: self) { newTime in
            progressExpectation.fulfill()
        }
        
        playerViewModel.isPlaying.observe(on: self) { isPlaying in
            if isPlaying {
                progressExpectation.fulfill()
            }
        }

        wait(for: [currentTimeExpectation], timeout: 3, enforceOrder: false)
        playerViewModel.pause()
    }
    
    func testPause() {
        
        playerViewModel.togglePlay()
        playerViewModel.togglePlay()
        
        let currentTimeExpectation = expectation(description: "Current time is changed")
        currentTimeExpectation.isInverted = true
        
        let progressExpectation = expectation(description: "Progress time is changed")
        progressExpectation.isInverted = true
        
        playerViewModel.currentTime.observe(on: self) { _ in
            currentTimeExpectation.fulfill()
        }

        playerViewModel.progress.observe(on: self) { _ in
            progressExpectation.fulfill()
        }

        wait(for: [currentTimeExpectation, progressExpectation], timeout: 3, enforceOrder: false)
    }
}
