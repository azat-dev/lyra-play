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

    private var showMediaInfoUseCase: ShowMediaInfoUseCase!
    private var imagesRepository: FilesRepositoryMock!
    private var libraryRepository: AudioLibraryRepositoryMock!
    private var viewModel: LibraryItemViewModel!
    private var coordinator: LibraryItemCoordinatorMock!
    
    func setUpViewModel(trackId: UUID) async {

        libraryRepository = AudioLibraryRepositoryMock()
        imagesRepository = FilesRepositoryMock()
        coordinator = LibraryItemCoordinatorMock()
        
        showMediaInfoUseCase = DefaultShowMediaInfoUseCase(
            audioLibraryRepository: libraryRepository,
            imagesRepository: imagesRepository,
            defaultImage: "defaultImage".data(using: .utf8)!
        )
        
        viewModel = DefaultLibraryItemViewModel(
            trackId: trackId,
            coordinator: coordinator,
            showMediaInfoUseCase: showMediaInfoUseCase
        )
    }
    
    func testLoad() async throws {
        
        let trackId = UUID()
        
        await setUpViewModel(trackId: trackId)
        
        let initialMediaInfoExpectation = expectation(description: "Initial mediaInfo fullfiled")
        let loadedMediaInfoExpectation = expectation(description: "Loaded mediaInfo fullfiled")
        
        viewModel.info.observe(on: self) { info in
            
            guard let info = info else {
                initialMediaInfoExpectation.fulfill()
            }
            
            loadedMediaInfoExpectation.fulfill()
        }
        
        let result = await viewModel.load()
        try AssertResultSucceded(result)
        
        let isPlaying = viewModel.isPlaying.value
        XCTAssertEqual(isPlaying, false)
    }
    
    func testLoadNotExistingTrack() async throws {
        
        let trackId = UUID()
        
        await setUpViewModel(trackId: trackId)
        
        let initialMediaInfoExpectation = expectation(description: "Initial mediaInfo fullfiled")
        let loadedMediaInfoExpectation = expectation(description: "Loaded mediaInfo fullfiled")
        
        let result = await viewModel.load()
        let error = try AssertResultFailed(result)
        
        guard case .trackNotFound = error else {
            XCTFail("Wrong error")
            return
        }
    }
)

// MARK: - Mocks
    
private final class LibraryItemCoordinatorMock: LibraryItemCoordinator {

    func chooseSubtitles() async -> Result<URL?, Error> {
        
    }
}
