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
        useCase: Any,
        subtitlesRepository: SubtitlesRepository,
        subtitlesParser: SubtitlesParser,
        subtitlesFilesRepository: FilesRepository
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
}

// MARK: - Mocks

private final class SubtitlesParserMock: SubtitlesParser {

    func parse(_ text: String) async -> Result<Subtitles, SubtitlesParserError> {
        
        let subtitles = Subtitles(sentences: [])
        return .success(subtitles)
    }
}

private final class SubtitlesRepositoryMock: SubtitlesRepository {
    
    public var items = [SubtitlesInfo]()
    
    func put(info item: SubtitlesInfo) async -> Result<SubtitlesInfo, SubtitlesRepositoryError> {
        
        let index = items.firstIndex { $0.mediaFileId == item.mediaFileId && $0.language = item.language }
        
        guard let index = index else {
            items.append(item)
            return .success(item)
        }
        
        items[index] = item
        return .success(item)
    }
    
    func fetch(mediaFileId: UUID, language: String) async -> Result<SubtitlesInfo, SubtitlesRepositoryError> {
        
        let item = items.first { $0.mediaFileId == mediaFileId && $0.language = language }
        
        guard let item = item else {
            return .failure(.itemNotFound)
        }
        
        return .success(item)
    }
    
    func list() async -> Result<[SubtitlesInfo], SubtitlesRepositoryError> {
        return .success(items)
    }
    
    func list(mediaFileId: UUID) async -> Result<[SubtitlesInfo], SubtitlesRepositoryError> {
        return .success(items.filter { $0.mediaFileId == mediaFileId })
    }
    
    func delete(mediaFileId: UUID, language: String) async -> Result<Void, SubtitlesRepositoryError> {
        
        let index = items.firstIndex { $0.mediaFileId == item.mediaFileId && $0.language = item.language }
        
        guard let index = index else {
            return .failure(.itemNotFound)
        }

        items.remove(at: index)
        return .success(())
    }
}
