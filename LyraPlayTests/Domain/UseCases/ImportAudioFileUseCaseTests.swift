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
    
    override func setUpWithError() throws {
        
        let tagsParser = TagsParserMock()
        let audiofilesRepository = AudioFilesRepositoryMock()
        importAudioFileUseCase = DefaultImportAudioFileUseCase(audioFilesRepository)
    }
    
    private func getTestFiles(names: [String]) -> [Data] {
        return []
    }

    func test_importing_without_id3_tags() async throws {
        
        let testFilesOriginalNames = []
        let testFileNames = []
        let testFiles = getTestFiles(names: [""])
        
        for testFile in testFiles {
            await importAudioFileUseCase.importFile(data: testFiles)
        }
        
        let importedAudioFiles = await audioFilesRepository.list()
        
        XCTAssertEqual(importedAudioFiles.count, testFiles.count)
        XCTAssertEqual(importedAudioFiles.map { $0.name }.sorted(), testFilesOriginalNames.sorted()
    }
    
    func test_importing_with_id3_tags() async throws {
        
        let testFilesNames = []
            
        for testFile in testFiles {
            await importAudioFileUseCase.importFile(data: testFiles)
        }
        let testFiles = getTestFiles(names: [""])

        await importAudioFileUseCase.import(files: testFiles)
        
        let importedAudioFiles = await audioFilesRepository.list()
        
        XCTAssertEqual(importedAudioFiles.count, testFiles.count)
        
        let expectedAudioFiles = []
        XCTAssertEqual(importedAudioFiles.map { $0.name }.sorted(), expectedAudioFiles.sorted())
    }
}
