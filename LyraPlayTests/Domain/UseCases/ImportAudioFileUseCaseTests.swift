//
//  ImportAudioFileUseCaseTests.swift
//  LyraPlayTests
//
//  Created by Azat Kaiumov on 24.06.22.
//

import Foundation

import XCTest
@testable import LyraPlay

class ImportAudioFileUseCaseTests: XCTestCase {

    typealias SUT = (
        importAudioFileUseCase: ImportAudioFileUseCase,
        audioLibraryRepository: AudioLibraryRepository,
        imagesRepository: FilesRepository,
        audioFilesRepository: FilesRepository,
        tagsParser: TagsParserMock
    )
    
    func createSUT() -> SUT {

        let tagsParser = TagsParserMock()
        
        let audioLibraryRepository = AudioLibraryRepositoryMock()
        let imagesRepository = FilesRepositoryMock()
        let audioFilesRepository = FilesRepositoryMock()
        
        let importAudioFileUseCase = DefaultImportAudioFileUseCase(
            audioLibraryRepository: audioLibraryRepository,
            audioFilesRepository: audioFilesRepository,
            imagesRepository: imagesRepository,
            tagsParser: tagsParser
        )
        
        detectMemoryLeak(instance: importAudioFileUseCase)
        
        return (
            importAudioFileUseCase,
            audioLibraryRepository,
            imagesRepository,
            audioFilesRepository,
            tagsParser
        )
    }
    
    func testImportingWithoutId3Tags() async throws {
        
        let (
            importAudioFileUseCase,
            audioLibraryRepository,
            _,
            audioFilesRepository,
            tagsParser
        ) = createSUT()
        
        let testFilesOriginalNames: [String] = [
            "test1.mp3",
            "test2.mp3"
        ]
        
        let testFiles = [
            "test1".data(using: .utf8)!,
            "test2".data(using: .utf8)!,
        ]
        
        tagsParser.callback = { url in
            return AudioFileTags(duration: 10)
        }

        for (index, testFile) in testFiles.enumerated() {
            
            let originalName = testFilesOriginalNames[index]
            let result = await importAudioFileUseCase.importFile(originalFileName: originalName, fileData: testFile)
            try AssertResultSucceded(result, "Can't import a file: \(originalName)")
        }

        let resultListFiles = await audioLibraryRepository.listFiles()
        let importedAudioFiles = try AssertResultSucceded(resultListFiles)

        var importedData = [String: Data]()
        
        for libraryItem in importedAudioFiles {
            
            let result = await audioFilesRepository.getFile(name: libraryItem.audioFile)
            let data = try AssertResultSucceded(result)
            importedData[libraryItem.audioFile] = data
        }
        
        XCTAssertEqual(importedAudioFiles.count, testFiles.count)
        XCTAssertEqual(importedAudioFiles.map { $0.name }.sorted(), testFilesOriginalNames.sorted())
            
        let checkDataResults = importedAudioFiles.map { libraryItem -> Bool in
            
            let data = importedData[libraryItem.audioFile]
            return testFiles.contains(data!)
        }
        
        XCTAssertEqual(checkDataResults, testFiles.map { _ in true })
    }

    func testImportingWithId3Tags() async throws {
        
        let (
            importAudioFileUseCase,
            audioLibraryRepository,
            imagesRepository,
            audioFilesRepository,
            tagsParser
        ) = createSUT()

        
        let originalName = "test1.mp3"
        let testFile = "data".data(using: .utf8)!

        let testTags = AudioFileTags(
            title: "Title",
            genre: "Genre",
            coverImage: TagsImageData(
                data: "Data".data(using: .utf8)!,
                fileExtension: "png"
            ),
            artist: "Artist",
            duration: 10,
            lyrics: "Lyrics"
        )
        
        tagsParser.callback = { url in

            return testTags
        }

        let result = await importAudioFileUseCase.importFile(originalFileName: originalName, fileData: testFile)
        try AssertResultSucceded(result, "Can't import a file: \(originalName)")

        let resultListFiles = await audioLibraryRepository.listFiles()
        let importedAudioFiles = try AssertResultSucceded(resultListFiles)
        
        XCTAssertEqual(importedAudioFiles.count, 1)

        let imortedFile = try! XCTUnwrap(importedAudioFiles.first)
        
        XCTAssertEqual(imortedFile.name, testTags.title)
        XCTAssertEqual(imortedFile.genre, testTags.genre)
        XCTAssertEqual(imortedFile.artist, testTags.artist)
        XCTAssertEqual(imortedFile.duration, testTags.duration)

        let resutlAudioData = await audioFilesRepository.getFile(name: imortedFile.audioFile)
        let audioData = try AssertResultSucceded(resutlAudioData)
        XCTAssertEqual(audioData, testFile)
        
        let resultCoverImageData = await imagesRepository.getFile(name: imortedFile.coverImage!)
        let imageData = try AssertResultSucceded(resultCoverImageData)
        XCTAssertEqual(imageData, testTags.coverImage?.data)
    }
    
    func testFetchingData() async throws {
        
        let (
            importAudioFileUseCase,
            _,
            _,
            audioFilesRepository,
            tagsParser
        ) = createSUT()

        tagsParser.callback = { data in
            return AudioFileTags(
                title: "Test",
                genre: nil,
                coverImage: nil,
                artist: nil,
                duration: 10,
                lyrics: nil
            )
        }
        
        let data = "test".data(using: .utf8)!
        
        let resultImport = await importAudioFileUseCase.importFile(
            originalFileName: "Test1",
            fileData: data
        )
        
        let fileInfo = try AssertResultSucceded(resultImport)
        let resultFileData = await audioFilesRepository.getFile(name: fileInfo.audioFile)
        let fileData = try AssertResultSucceded(resultFileData)
        
        XCTAssertEqual(fileData, data)
    }
}
