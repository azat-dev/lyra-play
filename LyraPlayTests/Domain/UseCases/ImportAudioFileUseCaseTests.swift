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

    private var tagsParserCallback: TagsParserCallback?
    private var imagesRepository: FilesRepository!
    private var audioFilesRepository: FilesRepository!
    private var audioLibraryRepository: AudioLibraryRepository!
    private var importAudioFileUseCase: ImportAudioFileUseCase!
    
    override func setUp() {

        tagsParserCallback = nil
        
        let tagsParser = TagsParserMock { [weak self] data in
            self?.tagsParserCallback?(data)
        }
        
        audioLibraryRepository = AudioFilesRepositoryMock()
        imagesRepository = FilesRepositoryMock()
        audioFilesRepository = FilesRepositoryMock()
        
        importAudioFileUseCase = DefaultImportAudioFileUseCase(
            audioLibraryRepository: audioLibraryRepository,
            imagesRepository: imagesRepository,
            tagsParser: tagsParser,
            audioFilesRepository: audioFilesRepository
        )
    }
    
    func testImportingWithoutId3Tags() async throws {
        
        let testFilesOriginalNames: [String] = [
            "test1.mp3",
            "test2.mp3"
        ]
        
        let testFiles = [
            "test1".data(using: .utf8)!,
            "test2".data(using: .utf8)!,
        ]

        for (index, testFile) in testFiles.enumerated() {
            
            let originalName = testFilesOriginalNames[index]
            let result = await importAudioFileUseCase.importFile(originalFileName: originalName, fileData: testFile)
            AssertResultSucceded(result, "Can't import a file: \(originalName)")
        }

        let resultListFiles = await audioLibraryRepository.listFiles()
        let importedAudioFiles = AssertResultSucceded(resultListFiles)

        XCTAssertEqual(importedAudioFiles.count, testFiles.count)
        XCTAssertEqual(importedAudioFiles.map { $0.name }.sorted(), testFilesOriginalNames.sorted())
    }

    func testImportingWithId3Tags() async throws {

        let testFilesOriginalNames = [
            "test1.mp3",
            "test2.mp3",
        ]
        
        let testFiles = testFilesOriginalNames.map { $0.data(using: .utf8)! }
        
        let testTags = (0..<testFiles.count).map { index in
            
            return AudioFileTags(
                title: "Title \(index)",
                genre: "Genre \(index)",
                coverImage: TagsImageData(
                    data: "Genre \(index)".data(using: .utf8)!,
                    fileExtension: index % 2 == 0 ? "png" : "jpeg"
                ),
                artist: "Artist \(index)",
                lyrics: "Lyrics \(index)"
            )
        }
        
        tagsParserCallback = { data in
            let index = testFiles.firstIndex(of: data)!
            return testTags[index]
        }
        
        for (index, testFile) in testFiles.enumerated() {
            
            let originalName = testFilesOriginalNames[index]
            let result = await importAudioFileUseCase.importFile(originalFileName: originalName, fileData: testFile)

            AssertResultSucceded(result, "Can't import a file: \(originalName)")
        }

        let resultListFiles = await audioLibraryRepository.listFiles()
        let importedAudioFiles = AssertResultSucceded(resultListFiles)

        XCTAssertEqual(importedAudioFiles.count, testFiles.count)
        
        let importedAudioFilesSorted = testTags.map { tag in importedAudioFiles.first(where: { $0.name == tag.title }) }

        let resultNames = importedAudioFilesSorted.map { $0!.name }
        let expectedNames = testTags.map { $0.title! }

        XCTAssertEqual(resultNames, expectedNames)
        
        let resultArtists = importedAudioFilesSorted.map { $0!.artist! }
        let expectedArtists = testTags.map { $0.artist! }

        XCTAssertEqual(resultArtists, expectedArtists)
        
        let resultGenres = importedAudioFilesSorted.map { $0!.genre! }
        let expectedGenres = testTags.map { $0.genre! }

        XCTAssertEqual(resultGenres, expectedGenres)
        
        let resultImagesNames = importedAudioFilesSorted.map { $0!.coverImage! }
        var resultImages: [Data] = []
        
        for imageName in resultImagesNames {
            
            let result = await imagesRepository.getFile(name: imageName)
            let data = AssertResultSucceded(result)
            
            resultImages.append(data)
        }
        
        let expectedImages = testTags.map { $0.coverImage!.data }
        XCTAssertEqual(resultImages, expectedImages)
        
        let expectedImagesExtensions = testTags.map { $0.coverImage!.fileExtension }
        let resultExtensions = importedAudioFiles.map { $0.coverImage!.components(separatedBy: ".").last! }
        
        XCTAssertEqual(resultExtensions, expectedImagesExtensions)
    }
    
    func testFetchingData() async {
        
        tagsParserCallback = { data in
            return AudioFileTags(
                title: "Test",
                genre: nil,
                coverImage: nil,
                artist: nil,
                lyrics: nil
            )
        }
        
        let data = "test".data(using: .utf8)!
        
        let resultImport = await importAudioFileUseCase.importFile(
            originalFileName: "Test1",
            fileData: data
        )
        
        let fileInfo = AssertResultSucceded(resultImport)
        let resultFileData = await audioFilesRepository.getFile(name: fileInfo.fileName)
        let fileData = AssertResultSucceded(resultFileData)
        
        XCTAssertEqual(fileData, data)
    }
}
