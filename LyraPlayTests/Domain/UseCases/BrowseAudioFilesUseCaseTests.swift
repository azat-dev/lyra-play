//
//  BrowseAudioLibraryUseCaseTests.swift
//  LyraPlayTests
//
//  Created by Azat Kaiumov on 27.06.22.
//

import XCTest
import LyraPlay

class BrowseAudioLibraryUseCaseTests: XCTestCase {

    typealias SUT = (
        useCase: BrowseAudioLibraryUseCase,
        audioLibraryRepository: AudioLibraryRepository,
        imagesRepository: FilesRepository
    )

    func createSUT() -> SUT {
        
        let audioLibraryRepository = AudioLibraryRepositoryMock()
        let imagesRepository = FilesRepositoryMock()
        
        let useCase = BrowseAudioLibraryUseCaseImpl(
            audioLibraryRepository: audioLibraryRepository,
            imagesRepository: imagesRepository
        )
        
        detectMemoryLeak(instance: useCase)
        
        return (
            useCase,
            audioLibraryRepository,
            imagesRepository
        )
    }
    
    private func getTestFile(index: Int) -> (info: AudioFileInfo, data: Data) {
        return (
            info: AudioFileInfo.create(name: "Test \(index)", duration: 10, audioFile: "test.mp3"),
            data: "Test \(index)".data(using: .utf8)!
        )
    }
    
    func testListFiles() async throws {
        
        let (useCase, audioLibraryRepository, _) = createSUT()
        
        let numberOfTestFiles = 5
        let testFiles = (0..<numberOfTestFiles).map { self.getTestFile(index: $0) }
        
        for file in testFiles {
            let _ = await audioLibraryRepository.putFile(info: file.info)
        }
        
        let result = await useCase.listFiles()
        let receivedFiles = try! result.get()
        
        let expectedFileNames = testFiles.map { $0.info.name }
        XCTAssertEqual(receivedFiles.map { $0.name }, expectedFileNames)
    }
    
    func testGetFileInfo() async {
        
        let (useCase, audioLibraryRepository, _) = createSUT()
        
        let numberOfTestFiles = 5
        let testFiles = (0..<numberOfTestFiles).map { self.getTestFile(index: $0) }
        
        for file in testFiles {
            let result = await audioLibraryRepository.putFile(info: file.info)
            let savedFile = try! result.get()
            
            let infoResult = await useCase.getFileInfo(fileId: savedFile.id!)
            let receivedFile = try! infoResult.get()
            
            XCTAssertEqual(receivedFile, savedFile)
        }
    }
    
    func testGetFileInfoNotExisting() async throws {
        
        let (useCase, _, _) = createSUT()
        
        let infoResult = await useCase.getFileInfo(fileId: UUID())
        XCTAssertEqual(infoResult, .failure(.fileNotFound))
    }
    
    func testFetchImage() async throws {
        
        let (useCase, _, imagesRepository) = createSUT()
        
        let testImageName1 = "image1.png"
        let testImageName2 = "image2.jpeg"
        
        let testImage1 = "image1".data(using: .utf8)!
        let testImage2 = "image2".data(using: .utf8)!
        
        let put1 = await imagesRepository.putFile(name: testImageName1, data: testImage1)
        try AssertResultSucceded(put1)
        
        let put2 = await imagesRepository.putFile(name: testImageName2, data: testImage2)
        try AssertResultSucceded(put2)
        
        let resultImage1 = await useCase.fetchImage(name: testImageName1)
        let imageData1 = try AssertResultSucceded(resultImage1)
        
        XCTAssertEqual(imageData1, testImage1)
        
        let resultImage2 = await useCase.fetchImage(name: testImageName2)
        let imageData2 = try AssertResultSucceded(resultImage2)
        
        XCTAssertEqual(imageData2, testImage2)
    }
}
