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
        
        showMediaInfoUseCase = ShowMediaInfoUseCaseMock()
        currentPlayerStateUseCase = CurrentPlayerStateUseCaseMock(showMediaInfoUseCase: showMediaInfoUseCase)
        playerControlUseCase = PlayerControlUseCaseMock(currentPlayerStateUseCase: currentPlayerStateUseCase)
        
        viewModel = DefaultLibraryItemViewModel(
            trackId: trackId,
            coordinator: coordinator,
            showMediaInfoUseCase: showMediaInfoUseCase,
            currentPlayerStateUseCase: currentPlayerStateUseCase,
            playerControlUseCase: playerControlUseCase
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
            artist: "Artist"
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
        
        let playingSequence = AssertSequence(testCase: self, values: [false, true, false, true])
        playingSequence.observe(viewModel.isPlaying)
        
        let _ = await viewModel.load()

        await viewModel.togglePlay()
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

final class CurrentPlayerStateUseCaseMock: CurrentPlayerStateUseCase {
    
    var info: Observable<MediaInfo?> = Observable(nil)
    
    var state: Observable<PlayerState> = Observable(.stopped)
    
    var currentTime: Observable<Double> = Observable(0.0)
    
    var volume: Observable<Double> = Observable(0.0)
    
    private var showMediaInfoUseCase: ShowMediaInfoUseCaseMock
    
    init(showMediaInfoUseCase: ShowMediaInfoUseCaseMock) {
        self.showMediaInfoUseCase = showMediaInfoUseCase
    }
    
    public func setTrack(trackId: UUID?) async {

        guard let trackId = trackId else {
            info.value = nil
            return
        }
        
        let result = await showMediaInfoUseCase.fetchInfo(trackId: trackId)
        guard case .success(let data) = result else {
            return
        }
        
        info.value = data
    }
    
}
