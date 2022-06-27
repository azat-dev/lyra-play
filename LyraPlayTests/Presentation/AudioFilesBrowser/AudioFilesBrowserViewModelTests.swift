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

//    private var filesRepository: AudioFilesRepository!
//    private var useCase: BrowseAudioFilesUseCase!
//    private var viewModel: AudioFilesBrowserViewModel!
//    
//    override func setUp() async throws {
//        
//        filesRepository = AudioFilesRepositoryMock()
//        useCase = DefaultBrowseAudioFilesUseCase(audioFilesRepository: filesRepository)
//        viewModel = DefaultAudioFilesBrowserViewModel(browseUseCase: useCase)
//    }
//    
//    private func getTestFile(index: Int) -> (info: AudioFileInfo, data: Data) {
//        return (
//            info: AudioFileInfo.create(name: "Test \(index)"),
//            data: "Test \(index)".data(using: .utf8)!
//        )
//    }
//    
//    func testListFiles() async throws {
//        
//        let numberOfTestFiles = 5
//        let testFiles = (0..<numberOfTestFiles).map { self.getTestFile(index: $0) }
//        
//        for file in testFiles {
//            let _ = await filesRepository.putFile(info: file.info, data: file.data)
//        }
//        
//        let expectation = XCTestExpectation()
//        
//        viewModel.bind(self) { [weak self] files in
//     
//            let expectedTitles = testFiles.map { $0.name }
//            let expectedDescriptions  = testFiles.map { $0.description }
//            
//            XCTAssertEqual(files.map { $0.title }, expectedTitles)
//            XCTAssertEqual(files.map { $0.description }, expectedDescriptions)
//            
//            expectation.fulfill()
//        }
//        
//        await waitForExpectations(timeout: 5, handler: nil)
//    }
}

