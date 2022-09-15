//
//  ImportAudioFileUseCaseTests.swift
//  LyraPlayTests
//
//  Created by Azat Kaiumov on 24.06.22.
//

import Foundation

import XCTest
@testable import LyraPlay
import Mockingbird

class ImportAudioFileUseCaseTests: XCTestCase {

    typealias SUT = (
        useCase: ImportAudioFileUseCase,
        mediaLibraryRepository: MediaLibraryRepository,
        imagesRepository: FilesRepository,
        audioFilesRepository: FilesRepository,
        tagsParser: TagsParserMock
    )
    
    func createSUT() -> SUT {

        let tagsParser = mock(TagsParser.self)
        
        let mediaLibraryRepository = MediaLibraryRepositoryMock2()
        let imagesRepository = FilesRepositoryMock2()
        let audioFilesRepository = FilesRepositoryMock2()
        
        let useCase = ImportAudioFileUseCaseImpl(
            mediaLibraryRepository: mediaLibraryRepository,
            audioFilesRepository: audioFilesRepository,
            imagesRepository: imagesRepository,
            tagsParser: tagsParser
        )
        
        detectMemoryLeak(instance: useCase)
        
        return (
            useCase,
            mediaLibraryRepository,
            imagesRepository,
            audioFilesRepository,
            tagsParser
        )
    }
    
    func test_import_without_id3_tags() async throws {

        // Given
        let sut = createSUT()
        
        let testFilesOriginalNames: [String] = [
            "test1.mp3",
            "test2.mp3"
        ]
        
        let testFiles = [
            "test1".data(using: .utf8)!,
            "test2".data(using: .utf8)!,
        ]
        
        given(await sut.tagsParser.parse(url: any()))
            .willReturn(.success(AudioFileTags(duration: 10)))

        // When
        for (index, testFile) in testFiles.enumerated() {
            
            let originalName = testFilesOriginalNames[index]
            let result = await sut.useCase.importFile(
                originalFileName: originalName,
                fileData: testFile
            )
            try AssertResultSucceded(result, "Can't import a file: \(originalName)")
        }

        // Then
        let resultListFiles = await sut.mediaLibraryRepository.listFiles()
        let importedAudioFiles = try AssertResultSucceded(resultListFiles)

        var importedData = [String: Data]()
        
        for libraryItem in importedAudioFiles {
            
            let result = await sut.audioFilesRepository.getFile(name: libraryItem.audioFile)
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

    func test_importing_with_id3_tags() async throws {
        
        let sut = createSUT()

        // Given
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
        
        given(await sut.tagsParser.parse(url: any()))
            .willReturn(.success(testTags))

        // When
        let result = await sut.useCase.importFile(
            originalFileName: originalName,
            fileData: testFile
        )
        try AssertResultSucceded(result, "Can't import a file: \(originalName)")

        let resultListFiles = await sut.mediaLibraryRepository.listFiles()
        let importedAudioFiles = try AssertResultSucceded(resultListFiles)
        
        XCTAssertEqual(importedAudioFiles.count, 1)

        let imortedFile = try! XCTUnwrap(importedAudioFiles.first)
        
        XCTAssertEqual(imortedFile.name, testTags.title)
        XCTAssertEqual(imortedFile.genre, testTags.genre)
        XCTAssertEqual(imortedFile.artist, testTags.artist)
        XCTAssertEqual(imortedFile.duration, testTags.duration)

        let resutlAudioData = await sut.audioFilesRepository.getFile(name: imortedFile.audioFile)
        let audioData = try AssertResultSucceded(resutlAudioData)
        XCTAssertEqual(audioData, testFile)
        
        let resultCoverImageData = await sut.imagesRepository.getFile(name: imortedFile.coverImage!)
        let imageData = try AssertResultSucceded(resultCoverImageData)
        XCTAssertEqual(imageData, testTags.coverImage?.data)
    }
    
    func test_getFile() async throws {
        
        let sut = createSUT()

        // When
        let tagsData = AudioFileTags(
            title: "Test",
            genre: nil,
            coverImage: nil,
            artist: nil,
            duration: 10,
            lyrics: nil
        )
        
        given(await sut.tagsParser.parse(url: any()))
            .willReturn(.success(tagsData))
        
        let data = "test".data(using: .utf8)!
        
        let resultImport = await sut.useCase.importFile(
            originalFileName: "Test1",
            fileData: data
        )
        
        let fileInfo = try AssertResultSucceded(resultImport)
        
        // When
        let resultFileData = await sut.audioFilesRepository.getFile(name: fileInfo.audioFile)
        
        // Then
        let fileData = try AssertResultSucceded(resultFileData)
        XCTAssertEqual(fileData, data)
    }
}
