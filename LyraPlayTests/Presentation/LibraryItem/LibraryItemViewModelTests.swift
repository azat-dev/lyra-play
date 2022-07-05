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
    
    private var trackId: UUID!
    
    override func setUp() {
        
        coordinator = LibraryItemCoordinatorMock()
        trackId = UUID()
        
        showMediaInfoUseCase = ShowMediaInfoUseCaseMock()

        viewModel = DefaultLibraryItemViewModel(
            trackId: trackId,
            coordinator: coordinator,
            showMediaInfoUseCase: showMediaInfoUseCase
//            playerControlUseCase: playerControlUseCase
        )
    }
    
    func testLoadNotExistingTrack() async throws {
        
        let result = await viewModel.load()
        let error = try AssertResultFailed(result)
        XCTAssertNotNil(error)
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
        
        let result = await viewModel.load()
        try AssertResultSucceded(result)
        
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

        let playResult = await viewModel.togglePlay()
        try AssertResultSucceded(playResult)

        let pauseResult = await viewModel.togglePlay()
        try AssertResultSucceded(pauseResult)
        
        playingSequence.wait(timeout: 3, enforceOrder: true)
    }
}

// MARK: - Mocks
    
private final class LibraryItemCoordinatorMock: LibraryItemCoordinator {

    func chooseSubtitles() async -> Result<URL?, Error> {
        return .success(nil)
    }
}
