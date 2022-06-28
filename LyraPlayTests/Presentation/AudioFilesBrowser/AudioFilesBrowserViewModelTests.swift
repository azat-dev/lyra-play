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

    private var audioFilesRepository: AudioFilesRepository!
    private var useCase: BrowseAudioFilesUseCase!
    private var viewModel: AudioFilesBrowserViewModel!
    private var tagsParserCallback: TagsParserCallback?
    private var filesDelegate: AudioFilesBrowserUpdateDelegate? = nil
    
    override func setUp() async throws {
        
        filesDelegate = nil
        audioFilesRepository = AudioFilesRepositoryMock()
        useCase = DefaultBrowseAudioFilesUseCase(audioFilesRepository: audioFilesRepository)
        
        tagsParserCallback = nil
        let tagsParser = TagsParserMock(callback: { [weak self] data in self?.tagsParserCallback?(data) })
        
        let imagesRepository = FilesRepositoryMock()
        
        let importFileUseCase = DefaultImportAudioFileUseCase(
            audioFilesRepository: audioFilesRepository,
            imagesRepository: imagesRepository,
            tagsParser: tagsParser
        )
        
        let coordinator = AudioFilesBrowserCoordinatorMock()
        
        viewModel = DefaultAudioFilesBrowserViewModel(
            coordinator: coordinator,
            browseUseCase: useCase,
            importFileUseCase: importFileUseCase
        )
    }
    
    private func getTestFile(index: Int) -> (info: AudioFileInfo, data: Data) {
        return (
            info: AudioFileInfo.create(name: "Test \(index)"),
            data: "Test \(index)".data(using: .utf8)!
        )
    }
    
    func testListFiles() async throws {
        
        let numberOfTestFiles = 5
        let testFiles = (0..<numberOfTestFiles).map { self.getTestFile(index: $0) }
        
        for file in testFiles {
            let _ = await audioFilesRepository.putFile(info: file.info, data: file.data)
        }
        
        let expectation = XCTestExpectation()
        
        tagsParserCallback = { data in
            
            let index = testFiles.firstIndex { $0.data == data }
                                              
            guard let index = index else {
                fatalError()
            }
                                              
            return AudioFileTags(
                title: "Title \(index)",
                genre: "Genre \(index)",
                coverImage: TagsImageData(
                    data: "Cover \(index)".data(using: .utf8)!,
                    fileExtension:"png"
                ),
                artist: "Artist \(index)",
                lyrics: "Lyrics \(index)"
            )
        }
        
        filesDelegate = FilesDelegateMock(onUpdateFiles: { files in
            
            let expectedTitles = testFiles.map { $0.info.name }
            let expectedDescriptions  = testFiles.map { $0.info.artist ?? "" }
            
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
