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

    private var importAudioFileUseCase: ImportAudioFileUseCase!
    private var audioFilesRepository: AudioFilesRepository!
    private var tagsParser: TagsParser!
//
    override func setUpWithError() throws {

        let tagsParser = TagsParserMock()
        let audiofilesRepository = AudioFilesRepositoryMock()
//        importAudioFileUseCase = DefaultImportAudioFileUseCase(audioFilesRepository)
    }
//
//    private func getTestFiles(names: [String]) -> [Data] {
//        return []
//    }
//
//    func test_importing_without_id3_tags() async throws {
//
//        let testFilesOriginalNames = []
//        let testFileNames = []
//        let testFiles = getTestFiles(names: [""])
//
//        for testFile in testFiles {
//            await importAudioFileUseCase.importFile(data: testFiles)
//        }
//
//        let importedAudioFiles = await audioFilesRepository.list()
//
//        XCTAssertEqual(importedAudioFiles.count, testFiles.count)
//        XCTAssertEqual(importedAudioFiles.map { $0.name }.sorted(), testFilesOriginalNames.sorted()
//    }
//
//    func test_importing_with_id3_tags() async throws {
//
//        let testFilesNames = []
//
//        for testFile in testFiles {
//            await importAudioFileUseCase.importFile(data: testFiles)
//        }
//        let testFiles = getTestFiles(names: [""])
//
//        await importAudioFileUseCase.import(files: testFiles)
//
//        let importedAudioFiles = await audioFilesRepository.list()
//
//        XCTAssertEqual(importedAudioFiles.count, testFiles.count)
//
//        let expectedAudioFiles = []
//        XCTAssertEqual(importedAudioFiles.map { $0.name }.sorted(), expectedAudioFiles.sorted())
//    }
}

// MARK: - Mocks

fileprivate class TagsParserMock: TagsParser {
    
    
    func parse(data: Data) async -> Result<AudioFileTags, Error> {
        let tags = AudioFileTags(
            title: "Title",
            genre: "Genre",
            coverImage: "ImageData".data(using: .utf8),
            artist: "Artist",
            lyrics: "Lyrics"
        )
        
        return .success(tags)
    }
}

fileprivate class AudioFilesRepositoryMock: AudioFilesRepository {
    
    private var files = [AudioFileInfo]()
    
    func listFiles() async -> Result<[AudioFileInfo], AudioFilesRepositoryError> {
        return .success(files)
    }
    
    func getInfo(fileId: UUID) async -> Result<AudioFileInfo, AudioFilesRepositoryError> {
        let file = files.first { $0.id == fileId }
        guard let file = file else {
            return .failure(.fileNotFound)
        }

        return .success(file)
    }
    
    func putFile(info fileInfo: AudioFileInfo, data: Data) async -> Result<AudioFileInfo, AudioFilesRepositoryError> {
        
        guard fileInfo.id != nil else {
            
            let fileIndex = files.firstIndex(where: { $0.id == fileInfo.id })
            guard let fileIndex = fileIndex else {
                return .failure(.fileNotFound)
            }
            
            files[fileIndex] = fileInfo
            return .success(fileInfo)
        }
        
        var newFileInfo = fileInfo
        
        if newFileInfo.id == nil {
            newFileInfo.id = UUID()
        }
        
        files.append(newFileInfo)
        return .success(newFileInfo)
    }
    
    func delete(fileId: UUID) async -> Result<Void, AudioFilesRepositoryError> {
        files = files.filter { $0.id != fileId }
        
        return .success()
    }
}
