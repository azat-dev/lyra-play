//
//  AudioFilesBrowserViewModelTests.swift
//  LyraPlayTests
//
//  Created by Azat Kaiumov on 27.06.22.
//

import Foundation
import LyraPlay
import XCTest

class AudioFilesBrowserViewModelTests: XCTestCase {
    
    typealias SUT = (
        viewModel: AudioFilesBrowserViewModel,
        audioLibraryRepository: AudioLibraryRepository,
        imagesRepository: FilesRepository,
        useCase: BrowseAudioLibraryUseCase,
        tagsParser: TagsParserMock
    )
    
    func createSUT() -> SUT {
        
        let audioLibraryRepository = AudioLibraryRepositoryMock()
        let imagesRepository = FilesRepositoryMock()
        
        let useCase = DefaultBrowseAudioLibraryUseCase(
            audioLibraryRepository: audioLibraryRepository,
            imagesRepository: imagesRepository
        )
        
        let tagsParser = TagsParserMock()
        let audioFilesRepository = FilesRepositoryMock()
        
        let importFileUseCase = DefaultImportAudioFileUseCase(
            audioLibraryRepository: audioLibraryRepository,
            audioFilesRepository: audioFilesRepository,
            imagesRepository: imagesRepository,
            tagsParser: tagsParser
        )
        
        let coordinator = AudioFilesBrowserCoordinatorMock()
        
        let viewModel = DefaultAudioFilesBrowserViewModel(
            coordinator: coordinator,
            browseUseCase: useCase,
            importFileUseCase: importFileUseCase,
            playerControlUseCase: PlayerControlUseCaseMock()
        )
        
        detectMemoryLeak(instance: viewModel)
        
        return (
            viewModel,
            audioLibraryRepository,
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
            audioLibraryRepository,
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
            let _ = await audioLibraryRepository.putFile(info: file.info)
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

fileprivate class AudioFilesBrowserCoordinatorMock: AudioFilesBrowserCoordinator {
    func openLibraryItem(trackId: UUID) {
    }
    
    func chooseFiles(completion: @escaping ([URL]?) -> Void) {
        completion(nil)
    }
    
    func openAudioPlayer(trackId: UUID) {
    }
}

fileprivate class FilesDelegateMock: AudioFilesBrowserUpdateDelegate {
    
    typealias FilesUpdateCallback = (_ updatedFiles: [AudioFilesBrowserCellViewModel]) -> Void
    private var onUpdateFiles: FilesUpdateCallback
    
    init(onUpdateFiles: @escaping FilesUpdateCallback) {
        
        self.onUpdateFiles = onUpdateFiles
    }
    
    func filesDidUpdate(updatedFiles: [AudioFilesBrowserCellViewModel]) {
        
        onUpdateFiles(updatedFiles)
    }
}
