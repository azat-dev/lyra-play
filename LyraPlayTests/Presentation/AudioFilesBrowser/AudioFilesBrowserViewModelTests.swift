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

    private var audioLibraryRepository: AudioLibraryRepository!
    private var imagesRepository: FilesRepository!
    
    private var useCase: BrowseAudioLibraryUseCase!
    private var viewModel: AudioFilesBrowserViewModel!
    private var tagsParserCallback: TagsParserCallback?
    private var filesDelegate: AudioFilesBrowserUpdateDelegate? = nil
    
    override func setUp() async throws {
        
        filesDelegate = nil
        audioLibraryRepository = AudioFilesRepositoryMock()
        imagesRepository = FilesRepositoryMock()
        
        useCase = DefaultBrowseAudioLibraryUseCase(
            audioLibraryRepository: audioLibraryRepository,
            imagesRepository: imagesRepository
        )
        
        tagsParserCallback = nil
        let tagsParser = TagsParserMock(callback: { [weak self] data in
            
            guard let tagsParserCallback = self?.tagsParserCallback else {
                fatalError()
            }
            
            return tagsParserCallback(data)
        })
        
        let audioFilesRepository = FilesRepositoryMock()
        let imagesRepository = FilesRepositoryMock()
        
        let importFileUseCase = DefaultImportAudioFileUseCase(
            audioLibraryRepository: audioLibraryRepository,
            audioFilesRepository: audioFilesRepository,
            imagesRepository: imagesRepository,
            tagsParser: tagsParser
        )
        
        let coordinator = AudioFilesBrowserCoordinatorMock()
        
        viewModel = DefaultAudioFilesBrowserViewModel(
            coordinator: coordinator,
            browseUseCase: useCase,
            importFileUseCase: importFileUseCase,
            audioPlayerUseCase: AudioPlayerUseCaseMock()
        )
    }
    
    private func getTestFile(index: Int) -> (info: AudioFileInfo, data: Data) {
        return (
            info: AudioFileInfo.create(name: "Test \(index)", duration: 19, audioFile: "test.mp3"),
            data: "Test \(index)".data(using: .utf8)!
        )
    }
    
    func testListFiles() async throws {
        
        let numberOfTestFiles = 5
        let testFiles = (0..<numberOfTestFiles).map { self.getTestFile(index: $0) }
        let testImages = (0..<numberOfTestFiles).map { index in
            return "Cover \(index)".data(using: .utf8)!
        }
        
        for file in testFiles {
            let _ = await audioLibraryRepository.putFile(info: file.info, data: file.data)
        }
        
        let expectation = XCTestExpectation()
        
        tagsParserCallback = { url in
            
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
        
        filesDelegate = FilesDelegateMock(onUpdateFiles: { files in
            
            let expectedTitles = testFiles.map { $0.info.name }
            let expectedDescriptions = testFiles.map { $0.info.artist ?? "" }
            
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

fileprivate class AudioPlayerUseCaseMock: AudioPlayerUseCase {
    
    func setTrack(fileId: UUID) async -> Result<Void, AudioPlayerUseCaseError> {
        fatalError()
    }
    
    func getCurrentTrackId() async -> Result<UUID?, AudioPlayerUseCaseError> {
        fatalError()
    }
    
    func play() async -> Result<Void, AudioPlayerUseCaseError> {
        fatalError()
    }
    
    func pause() async -> Result<Void, AudioPlayerUseCaseError> {
        fatalError()
    }
}
