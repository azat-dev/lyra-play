//
//  MediaLibraryBrowserViewModelTests.swift
//  LyraPlayTests
//
//  Created by Azat Kaiumov on 27.06.22.
//

import Foundation
import XCTest
import Mockingbird

import LyraPlay

class MediaLibraryBrowserViewModelTests: XCTestCase {
    
    typealias SUT = (
        viewModel: MediaLibraryBrowserViewModel,
        mediaLibraryRepository: MediaLibraryRepository,
        imagesRepository: FilesRepository,
        useCase: BrowseMediaLibraryUseCase,
        tagsParser: TagsParserMock
    )
    
    func createSUT() -> SUT {
        
        let mediaLibraryRepository = MediaLibraryRepositoryMock()
        let imagesRepository = FilesRepositoryMock()
        
        let useCase = BrowseMediaLibraryUseCaseImpl(
            mediaLibraryRepository: mediaLibraryRepository,
            imagesRepository: imagesRepository
        )
        
        let tagsParser = TagsParserMock()
        let audioFilesRepository = FilesRepositoryMock()
        
        let importFileUseCase = ImportAudioFileUseCaseImpl(
            mediaLibraryRepository: mediaLibraryRepository,
            audioFilesRepository: audioFilesRepository,
            imagesRepository: imagesRepository,
            tagsParser: tagsParser
        )
        
        let delegate = mock(MediaLibraryBrowserViewModelDelegate.self)
        
        let viewModel = MediaLibraryBrowserViewModelImpl(
            delegate: delegate,
            browseUseCase: useCase,
            importFileUseCase: importFileUseCase
        )
        
        detectMemoryLeak(instance: viewModel)
        
        return (
            viewModel,
            mediaLibraryRepository,
            imagesRepository,
            useCase,
            tagsParser
        )
    }
    
    private func getTestFile(index: Int) -> (info: AudioFileInfo, data: Data) {
        return (
            info: AudioFileInfo.create(name: "Test \(index)", duration: 19, audioFile: "test.mp3"),
            data: "Test \(index)".data(using: .utf8)!
        )
    }
    
    func testListFiles() async throws {
        
        var (
            viewModel,
            mediaLibraryRepository,
            _,
            _,
            tagsParser
        ) = createSUT()
        
        let numberOfTestFiles = 5
        let testFiles = (0..<numberOfTestFiles).map { self.getTestFile(index: $0) }
        let testImages = (0..<numberOfTestFiles).map { index in
            return "Cover \(index)".data(using: .utf8)!
        }
        
        for file in testFiles {
            let _ = await mediaLibraryRepository.putFile(info: file.info)
        }
        
        let expectation = XCTestExpectation()
        
        tagsParser.callback = { url in
            
            let index = testFiles.firstIndex { $0.info.audioFile == url.absoluteString }
            
            guard let index = index else {
                fatalError()
            }
            
            return AudioFileTags(
                title: "Title \(index)",
                genre: "Genre \(index)",
                coverImage: TagsImageData(
                    data: testImages[index],
                    fileExtension:"png"
                ),
                artist: "Artist \(index)",
                duration: 10,
                lyrics: "Lyrics \(index)"
            )
        }
        
        let filesDelegate = FilesDelegateMock(onUpdateFiles: { files in
            
            let expectedTitles = testFiles.map { $0.info.name }
            let expectedDescriptions = testFiles.map { $0.info.artist ?? "Unknown" }
            
            XCTAssertEqual(files.map { $0.title }, expectedTitles)
            XCTAssertEqual(files.map { $0.description }, expectedDescriptions)
            
            expectation.fulfill()
        })
        
        viewModel.filesDelegate = filesDelegate
        
        await viewModel.load()
        wait(for: [expectation], timeout: 3, enforceOrder: true)
    }
}

// MARK: - Mocks

fileprivate class FilesDelegateMock: MediaLibraryBrowserUpdateDelegate {
    
    typealias FilesUpdateCallback = (_ updatedFiles: [MediaLibraryBrowserCellViewModel]) -> Void
    private var onUpdateFiles: FilesUpdateCallback
    
    init(onUpdateFiles: @escaping FilesUpdateCallback) {
        
        self.onUpdateFiles = onUpdateFiles
    }
    
    func filesDidUpdate(updatedFiles: [MediaLibraryBrowserCellViewModel]) {
        
        onUpdateFiles(updatedFiles)
    }
}
