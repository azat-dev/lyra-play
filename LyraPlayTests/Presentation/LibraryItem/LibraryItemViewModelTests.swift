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
    private var coordinator: LibraryItemCoordinatorMock!
    private var playerControlUseCase: PlayerControlUseCaseMock!
    private var currentPlayerStateUseCase: CurrentPlayerStateUseCaseMock!
    
    override func setUp() async throws {
        coordinator = LibraryItemCoordinatorMock()
        
        showMediaInfoUseCase = ShowMediaInfoUseCaseMock()
        currentPlayerStateUseCase = CurrentPlayerStateUseCaseMock(showMediaInfoUseCase: showMediaInfoUseCase)
        playerControlUseCase = PlayerControlUseCaseMock(currentPlayerStateUseCase: currentPlayerStateUseCase)
    }
    
    func createViewModel(trackId: UUID) -> LibraryItemViewModel {
        
        let viewModel = DefaultLibraryItemViewModel(
            trackId: trackId,
            coordinator: coordinator,
            showMediaInfoUseCase: showMediaInfoUseCase,
            currentPlayerStateUseCase: currentPlayerStateUseCase,
            playerControlUseCase: playerControlUseCase
        )
        
        return viewModel
    }
    
    func testLoadNotExistingTrack() async throws {
        
        let viewModel = createViewModel(trackId: UUID())
        await viewModel.load()
        // TODO: Implement "doesn't exist" logic
    }
    
    private func setUpTestTrack(trackId: UUID) {
        
        showMediaInfoUseCase.tracks[trackId] = MediaInfo(
            id: trackId.uuidString,
            coverImage: Data(),
            title: "Test \(trackId)",
            duration: 20,
            artist: "Artist \(trackId)"
        )
    }
    
    func testLoad() async throws {
        
        let trackId = UUID()
        
        let viewModel = createViewModel(trackId: trackId)
        setUpTestTrack(trackId: trackId)
        
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
        
        let trackId = UUID()
        
        let viewModel = createViewModel(trackId: trackId)
        setUpTestTrack(trackId: trackId)
        
        let playingSequence = AssertSequence(testCase: self, values: [false, true, false, true])
        playingSequence.observe(viewModel.isPlaying)
        
        let _ = await viewModel.load()

        await viewModel.togglePlay()
        await viewModel.togglePlay()
        await viewModel.togglePlay()
        
        playingSequence.wait(timeout: 3, enforceOrder: true)
    }
    
    func testTogglePlayDifferentTrack() async throws {
        
        let trackId1 = UUID()
        
        let viewModel1 = createViewModel(trackId: trackId1)
        setUpTestTrack(trackId: trackId1)

        let trackId2 = UUID()
        
        let viewModel2 = createViewModel(trackId: trackId2)
        setUpTestTrack(trackId: trackId2)

        
        let playingSequence1 = AssertSequence(testCase: self, values: [false, true, false])
        playingSequence1.observe(viewModel1.isPlaying)
        
        let playingSequence2 = AssertSequence(testCase: self, values: [false, true])
        playingSequence2.observe(viewModel2.isPlaying)
        
        
        let _ = await viewModel1.load()
        await viewModel1.togglePlay()
        
        let _ = await viewModel2.load()
        await viewModel2.togglePlay()
        
        playingSequence1.wait(timeout: 3, enforceOrder: true)
        playingSequence2.wait(timeout: 3, enforceOrder: true)
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
