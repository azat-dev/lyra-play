//
//  BrowseAudioFilesUseCaseTests.swift
//  LyraPlayTests
//
//  Created by Azat Kaiumov on 27.06.22.
//

import XCTest
import LyraPlay

class BrowseAudioFilesUseCaseTests: XCTestCase {

    private var useCase: BrowseAudioFilesUseCase!
    private var filesRepository: AudioFilesRepository!
    
    override func setUp() async throws {
        
        let audioFilesRepository = AudioFilesRepositoryMock()
        
        useCase = DefaultBrowseAudioFilesUseCase(
            audioFilesRepository
        )
    }
    
    private func getTestFile(index: Int) -> (info: AudioFileInfo, data: Data) {
        return (
            info: AudioFileInfo.create(name: "Test \(index)"),
            data: "Test \(index)".data(using: .utf8)!
        )
    }
    
    private func testListFiles() async throws {
        
        let numberOfTestFiles = 5
        let testFiles = (0..<numberOfTestFiles).map { self.getTestFile(index: $0) }
        
        for file in testFiles {
            let _ = await filesRepository.putFile(info: file.info, data: file.data)
        }
        
        let result = await useCase.listFiles()
        let receivedFiles = try! result.get()
        
        let expectedFileNames = testFiles.map { $0.info.name }
        XCTAssertEqual(receivedFiles.map { $0.name }, expectedFileNames)
    }
    
    private func testGetFileInfo() async {
        
        let numberOfTestFiles = 5
        let testFiles = (0..<numberOfTestFiles).map { self.getTestFile(index: $0) }
        
        for file in testFiles {
            let result = await filesRepository.putFile(info: file.info, data: file.data)
            let savedFile = try! result.get()
            
            let result = await useCase.getFileInfo(for: savedFile.id!)
            let receivedFile = try! result.get()
            
            XCTAssertEqual(receivedFile, savedFile)
        }
    }
}
