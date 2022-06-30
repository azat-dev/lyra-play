//
//  BrowseAudioLibraryUseCaseTests.swift
//  LyraPlayTests
//
//  Created by Azat Kaiumov on 27.06.22.
//

import XCTest
import LyraPlay

class BrowseAudioLibraryUseCaseTests: XCTestCase {

    private var useCase: BrowseAudioLibraryUseCase!
    private var audioLibraryRepository: AudioLibraryRepository!
    private var imagesRepository: FilesRepository!

    override func setUp() async throws {
        
        audioLibraryRepository = AudioFilesRepositoryMock()
        imagesRepository = FilesRepositoryMock()
        
        useCase = DefaultBrowseAudioLibraryUseCase(
            audioLibraryRepository: audioLibraryRepository,
            imagesRepository: imagesRepository
        )
    }
    
    private func getTestFile(index: Int) -> (info: AudioFileInfo, data: Data) {
        return (
            info: AudioFileInfo.create(name: "Test \(index)", duration: 10, audioFile: "test.mp3"),
            data: "Test \(index)".data(using: .utf8)!
        )
    }
    
    func testListFiles() async throws {
        
        let numberOfTestFiles = 5
        let testFiles = (0..<numberOfTestFiles).map { self.getTestFile(index: $0) }
        
        for file in testFiles {
            let _ = await audioLibraryRepository.putFile(info: file.info, data: file.data)
        }
        
        let result = await useCase.listFiles()
        let receivedFiles = try! result.get()
        
        let expectedFileNames = testFiles.map { $0.info.name }
        XCTAssertEqual(receivedFiles.map { $0.name }, expectedFileNames)
    }
    
    func testGetFileInfo() async {
        
        let numberOfTestFiles = 5
        let testFiles = (0..<numberOfTestFiles).map { self.getTestFile(index: $0) }
        
        for file in testFiles {
            let result = await audioLibraryRepository.putFile(info: file.info, data: file.data)
            let savedFile = try! result.get()
            
            let infoResult = await useCase.getFileInfo(fileId: savedFile.id!)
            let receivedFile = try! infoResult.get()
            
            XCTAssertEqual(receivedFile, savedFile)
        }
    }
    
    func testGetFileInfoNotExisting() async throws {
        
        let infoResult = await useCase.getFileInfo(fileId: UUID())
        XCTAssertEqual(infoResult, .failure(.fileNotFound))
    }
    
    func testFetchImage() async {
        
        let testImageName1 = "image1.png"
        let testImageName2 = "image2.jpeg"
        
        let testImage1 = "image1".data(using: .utf8)!
        let testImage2 = "image2".data(using: .utf8)!
        
        let put1 = await imagesRepository.putFile(name: testImageName1, data: testImage1)
        AssertResultSucceded(put1)
        
        let put2 = await imagesRepository.putFile(name: testImageName2, data: testImage2)
        AssertResultSucceded(put2)
        
        let resultImage1 = await useCase.fetchImage(name: testImageName1)
        let imageData1 = AssertResultSucceded(resultImage1)
        
        XCTAssertEqual(imageData1, testImage1)
        
        let resultImage2 = await useCase.fetchImage(name: testImageName2)
        let imageData2 = AssertResultSucceded(resultImage2)
        
        XCTAssertEqual(imageData2, testImage2)
    }
}
