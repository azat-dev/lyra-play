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
    private var trackId: UUID!
    
    override func setUp() {
        
        let bundle = Bundle(for: type(of: self ))
        let testImageUrl = bundle.url(forResource: "test_cover_image", withExtension: "png")!
        let testImage = try! Data(contentsOf: testImageUrl)
        
        libraryRepository = AudioLibraryRepositoryMock()
        imagesRepository = FilesRepositoryMock()
        coordinator = LibraryItemCoordinatorMock()
        trackId = UUID()
        
        showMediaInfoUseCase = DefaultShowMediaInfoUseCase(
            audioLibraryRepository: libraryRepository,
            imagesRepository: imagesRepository,
            defaultImage: testImage
        )
        
        viewModel = DefaultLibraryItemViewModel(
            trackId: trackId,
            coordinator: coordinator,
            showMediaInfoUseCase: showMediaInfoUseCase
        )
    }
    
    func testLoad() async throws {
        
        var audioFile = AudioFileInfo.create(name: "Test", duration: 10, audioFile: "test.mp3")
        audioFile.id = trackId
        
        let resultLibraryItem = await libraryRepository.putNewFileWithId(info: audioFile)
        try AssertResultSucceded(resultLibraryItem)
        
        let initialMediaInfoExpectation = expectation(description: "Initial mediaInfo fulfilled")
        let loadedMediaInfoExpectation = expectation(description: "Loaded mediaInfo fulfilled")

        let initialPlayingExpectation = expectation(description: "Initial playing fulfilled")
        
        viewModel.info.observe(on: self) { info in
            
            guard let _ = info else {
                initialMediaInfoExpectation.fulfill()
                return
            }
            
            loadedMediaInfoExpectation.fulfill()
        }
        
        viewModel.isPlaying.observe(on: self) { isPlaying in
            
            guard isPlaying else {
                initialPlayingExpectation.fulfill()
                return
            }
        }
        
        let result = await viewModel.load()
        try AssertResultSucceded(result)
        
        wait(for: [initialMediaInfoExpectation, loadedMediaInfoExpectation], timeout: 3, enforceOrder: true)
        wait(for: [initialPlayingExpectation], timeout: 3, enforceOrder: true)

        let isPlaying = viewModel.isPlaying.value
        XCTAssertEqual(isPlaying, false)
    }
    
    func testLoadNotExistingTrack() async throws {
        
        let result = await viewModel.load()
        let error = try AssertResultFailed(result)
        XCTAssertNotNil(error)
        
        // TODO: Implement "doesn't exist" logic
    }
}

// MARK: - Mocks
    
private final class LibraryItemCoordinatorMock: LibraryItemCoordinator {

    func chooseSubtitles() async -> Result<URL?, Error> {
        return .success(nil)
    }
}
