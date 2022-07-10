//
//  ImportSubtitlesUseCaseTests.swift
//  LyraPlayTests
//
//  Created by Azat Kaiumov on 07.07.22.
//

import Foundation

import XCTest
import LyraPlay
import CoreMedia

class ImportSubtitlesUseCaseTests: XCTestCase {
 
    typealias SUT = (
        useCase: ImportSubtitlesUseCase,
        subtitlesRepository: SubtitlesRepositoryMock,
        subtitlesParser: SubtitlesParserMock,
        subtitlesFilesRepository: FilesRepositoryMock
    )
    
    func createSUT() -> SUT {
        
        let subtitlesRepository = SubtitlesRepositoryMock()
        let subtitlesParser = SubtitlesParserMock()
        let subtitlesFilesRepository = FilesRepositoryMock()
        
        let useCase = DefaultImportSubtitlesUseCase(
            subtitlesRepository: subtitlesRepository,
            subtitlesParser: subtitlesParser,
            subtitlesFilesRepository: subtitlesFilesRepository
        )
        
        detectMemoryLeak(instance: useCase)
        
        return (
            useCase,
            subtitlesRepository,
            subtitlesParser,
            subtitlesFilesRepository
        )
    }
    
    func testImportNewSubtitles() async throws {
        
        let (
            useCase,
            subtitlesRepository,
            subtitlesParser,
            subtitlesFilesRepository
        ) = createSUT()
        
        let testFileData = "testFileData".data(using: .utf8)!
        let language = "English"
        let trackId = UUID()
        let testFileName = "test.lrc"
        
        
        subtitlesParser.resolve = { _ in
            return .success(.init(sentences: []))
        }
        
        let importResult = await useCase.importFile(
            trackId: trackId,
            language: language,
            fileName: testFileName,
            data: testFileData
        )
        
        try AssertResultSucceded(importResult)
        
        let subtitleInfoResult = await subtitlesRepository.fetch(
            mediaFileId: trackId,
            language: language
        )
        
        let subtitles = try AssertResultSucceded(subtitleInfoResult)

        XCTAssertEqual(subtitles.mediaFileId, trackId)
        XCTAssertEqual(subtitles.language, language)
        
        let fileResult = await subtitlesFilesRepository.getFile(name: subtitles.file)
        let fileData = try AssertResultSucceded(fileResult)
        
        XCTAssertEqual(fileData, testFileData)
    }
    
    func testReplaceExistingSubtitles() async throws {
        
        let (
            useCase,
            subtitlesRepository,
            subtitlesParser,
            subtitlesFilesRepository
        ) = createSUT()
        
        let testFileData = "testFileData".data(using: .utf8)!
        let testFileDataUpdated = "testFileData".data(using: .utf8)!

        let language = "English"
        let trackId = UUID()
        let testFileName = "test.lrc"
        
        subtitlesParser.resolve = { _ in .success(.init(sentences: [])) }
        
        let _ = await useCase.importFile(
            trackId: trackId,
            language: language,
            fileName: testFileName,
            data: testFileData
        )
        
        let importResult = await useCase.importFile(
            trackId: trackId,
            language: language,
            fileName: testFileName,
            data: testFileDataUpdated
        )
        
        try AssertResultSucceded(importResult)
        
        let subtitleInfoResult = await subtitlesRepository.fetch(
            mediaFileId: trackId,
            language: language
        )
        
        let subtitles = try AssertResultSucceded(subtitleInfoResult)

        XCTAssertEqual(subtitles.mediaFileId, trackId)
        XCTAssertEqual(subtitles.language, language)
        
        let fileResult = await subtitlesFilesRepository.getFile(name: subtitles.file)
        let fileData = try AssertResultSucceded(fileResult)
        
        XCTAssertEqual(fileData, testFileDataUpdated)
    }
    
    func testImportWrongData() async throws {
        
        let (
            useCase,
            _,
            _,
            _
        ) = createSUT()
        
        let bundle = Bundle(for: type(of: self ))
        let url = bundle.url(forResource: "test_music_with_tags", withExtension: "mp3")!
        
        let testFileData = try Data(contentsOf: url)

        let language = "English"
        let trackId = UUID()
        let testFileName = "test.lrc"
        
        let importResult = await useCase.importFile(
            trackId: trackId,
            language: language,
            fileName: testFileName,
            data: testFileData
        )
        
        let error = try AssertResultFailed(importResult)
        
        guard case .wrongData = error else {
            XCTFail("Wrong error type \(error)")
            return
        }
    }
}
