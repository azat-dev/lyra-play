//
//  LibraryItemViewModel.swift
//  LyraPlayTests
//
//  Created by Azat Kaiumov on 02.07.22.
//

import Foundation
import LyraPlay
import XCTest

class LibraryItemViewModelTests: XCTestCase {

    private var showMediaInfoUseCase: ShowMediaInfoUseCaseMock!
    private var viewModel: LibraryItemViewModel!
    private var coordinator: LibraryItemCoordinatorMock!
    private var playerControlUseCase: PlayerControlUseCaseMock!
    private var currentPlayerStateUseCase: CurrentPlayerStateUseCaseMock!
    
    private var trackId: UUID!
    
    override func setUp() {
        
        coordinator = LibraryItemCoordinatorMock()
        trackId = UUID()
        
//        currentPlayerStateUseCase = CurrentPlayerStateUseCaseMock()
        playerControlUseCase = PlayerControlUseCaseMock(currentPlayerStateUseCase: currentPlayerStateUseCase)
        showMediaInfoUseCase = ShowMediaInfoUseCaseMock()
        
        
        viewModel = DefaultLibraryItemViewModel(
            trackId: trackId,
            coordinator: coordinator,
            showMediaInfoUseCase: showMediaInfoUseCase,
            playerControlUseCase: playerControlUseCase,
            currentPlayerStateUseCase: currentPlayerStateUseCase
        )
    }
    
    func testLoadNotExistingTrack() async throws {
        
        await viewModel.load()
        // TODO: Implement "doesn't exist" logic
    }
    
    private func setUpTestTrack() {
        
        showMediaInfoUseCase.tracks[trackId] = MediaInfo(
            id: trackId.uuidString,
            coverImage: Data(),
            title: "Test",
            duration: 20,
            artist: ""
        )
    }
    
    func testLoad() async throws {
        
        setUpTestTrack()
        
        let mediaInfoSequence = AssertSequence(testCase: self, values: [false, true])
        let playingSequence = AssertSequence(testCase: self, values: [false])
        
        mediaInfoSequence.observe(viewModel.info, mapper: { $0 != nil })
        playingSequence.observe(viewModel.isPlaying)
        
        await viewModel.load()
        
        playingSequence.wait(timeout: 3, enforceOrder: true)
        mediaInfoSequence.wait(timeout: 3, enforceOrder: true)

        let isPlaying = viewModel.isPlaying.value
        XCTAssertEqual(isPlaying, false)
    }
    
    func testTogglePlay() async throws {
        
        setUpTestTrack()
        
        let playingSequence = AssertSequence(testCase: self, values: [false, true, false])
        playingSequence.observe(viewModel.isPlaying)
        
        let _ = await viewModel.load()

        await viewModel.togglePlay()
        await viewModel.togglePlay()
        
        playingSequence.wait(timeout: 3, enforceOrder: true)
    }
}

// MARK: - Mocks
    
private final class LibraryItemCoordinatorMock: LibraryItemCoordinator {

    func chooseSubtitles() async -> Result<URL?, Error> {
        return .success(nil)
    }
}

private final class CurrentPlayerStateUseCaseMock: CurrentPlayerStateUseCase {
    
    var info: Observable<MediaInfo?> = Observable(nil)
    
    var state: Observable<PlayerState> = Observable(.stopped)
    
    var currentTime: Observable<Double> = Observable(0.0)
    
    var volume: Observable<Double> = Observable(0.0)
    
    private var playerControlUseCase: PlayerControlUseCase
    
    init(playerControlUseCase: PlayerControlUseCase) {
        self.playerControlUseCase = playerControlUseCase
    }
    
}
