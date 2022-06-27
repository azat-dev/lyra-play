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

    private func makeImportAudioFileUseCase(tagsParserCallback: @escaping TagsParserCallback) -> (useCase: ImportAudioFileUseCase, repository: AudioFilesRepository) {
        
        let tagsParser = TagsParserMock(callback: tagsParserCallback)
        let audioFilesRepository = AudioFilesRepositoryMock()
        
        let importAudioFileUseCase = DefaultImportAudioFileUseCase(
            audioFilesRepository: audioFilesRepository,
            tagsParser: tagsParser
        )

        return (useCase: importAudioFileUseCase, repository: audioFilesRepository)
    }

    func test_importing_without_id3_tags() async throws {
        
        let (importAudioFileUseCase, audioFilesRepository) = makeImportAudioFileUseCase(tagsParserCallback: { _ in
            return nil
        })

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
            
            if case .failure(let error) = result {
                print(error)
                XCTAssertFalse(true, "Can't import a file: \(originalName) \(error)")
                return
            }
        }

        let resultListFiles = await audioFilesRepository.listFiles()
        
        guard case .success(let importedAudioFiles) = resultListFiles else {
            XCTAssertFalse(true, "Can't get lis of files")
            return
        }

        XCTAssertEqual(importedAudioFiles.count, testFiles.count)
        XCTAssertEqual(importedAudioFiles.map { $0.name }.sorted(), testFilesOriginalNames.sorted())
    }

    func test_importing_with_id3_tags() async throws {

        let testFilesOriginalNames = [
            "test1.mp3",
            "test2.mp3",
        ]
        
        let testFiles = testFilesOriginalNames.map { $0.data(using: .utf8)! }
        
        let testTags = (0..<testFiles.count).map { index in
            
            return AudioFileTags(
                title: "Title \(index)",
                genre: "Genre \(index)",
                coverImage: "Cover \(index)".data(using: .utf8),
                artist: "Artist \(index)",
                lyrics: "Lyrics \(index)"
            )
        }
        
        
        let (importAudioFileUseCase, audioFilesRepository) = makeImportAudioFileUseCase(tagsParserCallback: { data in
            let index = testFiles.firstIndex(of: data)!
            return testTags[index]
        })

        for (index, testFile) in testFiles.enumerated() {
            
            let originalName = testFilesOriginalNames[index]
            let result = await importAudioFileUseCase.importFile(originalFileName: originalName, fileData: testFile)
            
            if case .failure(let error) = result {
                print(error)
                XCTAssertFalse(true, "Can't import a file: \(originalName) \(error)")
                return
            }
        }
        

        let resultListFiles = await audioFilesRepository.listFiles()
        
        guard case .success(let importedAudioFiles) = resultListFiles else {
            XCTAssertFalse(true, "Can't get list of files")
            return
        }

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
    }
}

// MARK: - Mocks

typealias TagsParserCallback = (_ data: Data) -> AudioFileTags?

fileprivate final class TagsParserMock: TagsParser {
    
    private var callback: TagsParserCallback
    
    init(callback: @escaping TagsParserCallback) {
        self.callback = callback
    }
    
    func parse(data: Data) async -> Result<AudioFileTags?, Error> {
        
        let tags = callback(data)
        return .success(tags)
    }
}
