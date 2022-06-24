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

    private func getTestFiles(names: [String]) -> [Data] {
        return []
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
            XCTAssertFalse(true, "Can't get lisf of files")
            return
        }

        XCTAssertEqual(importedAudioFiles.count, testFiles.count)
        XCTAssertEqual(importedAudioFiles.map { $0.name }.sorted(), testFilesOriginalNames.sorted())
    }
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

    private func updateExistingFile(info fileInfo: AudioFileInfo, data: Data) -> Result<AudioFileInfo, AudioFilesRepositoryError> {
    
        let fileIndex = files.firstIndex(where: { $0.id == fileInfo.id })
        guard let fileIndex = fileIndex else {
            return .failure(.fileNotFound)
        }
        
        files[fileIndex] = fileInfo
        return .success(fileInfo)
    }
    
    private func putNewFile(info fileInfo: AudioFileInfo, data: Data) -> Result<AudioFileInfo, AudioFilesRepositoryError> {
        
        var newFileInfo = fileInfo
        
        if newFileInfo.id == nil {
            newFileInfo.id = UUID()
        }
        
        files.append(newFileInfo)
        return .success(newFileInfo)
    }
    
    func putFile(info fileInfo: AudioFileInfo, data: Data) async -> Result<AudioFileInfo, AudioFilesRepositoryError> {
        
        guard fileInfo.id == nil else {
            return updateExistingFile(info: fileInfo, data: data)

        }
        
        return putNewFile(info: fileInfo, data: data)
    }
    
    func delete(fileId: UUID) async -> Result<Void, AudioFilesRepositoryError> {

        files = files.filter { $0.id != fileId }
        return .success(())
    }
}
