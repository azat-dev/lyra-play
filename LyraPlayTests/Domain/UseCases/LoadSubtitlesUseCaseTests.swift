//
//  LoadSubtitlesUseCaseTests.swift
//  LyraPlayTests
//
//  Created by Azat Kaiumov on 09.07.22.
//

import XCTest
import LyraPlay

class LoadSubtitlesUseCaseTests: XCTestCase {

    typealias SUT = (
        useCase: LoadSubtitlesUseCase,
        subtitlesRepository: SubtitlesRepositoryMock,
        subtitlesFiles: FilesRepositoryMock,
        subtitlesParser: SubtitlesParserMock
    )

    func createSUT() -> SUT {
        
        let audioLibraryRepository = AudioLibraryRepositoryMock()
        let imagesRepository = FilesRepositoryMock()
        let subtitlesParser = SubtitlesParserMock()
        
        let useCase = DefaultLoadSubtitlesUseCase(
            subtitlesRepository: subtitlesRepository,
            subtitlesFiles: subtitlesFiles,
            subtitlesParser: subtitlesParser
        )
        
        detectMemoryLeak(instance: useCase)
        
        return (
            useCase,
            subtitlesRepository,
            subtitlesFiles,
            subtitlesParser
        )
    }
    
    private func anyLanguage() -> String {
        return "English"
    }
    
    func testLoadFailIfSubtitlesDoesntExist() async throws {
        
        let sut = createSUT()

        let trackId = UUID()
        
        let result = await sut.useCase.load(for: trackId, language: anyLanguage())
        let error = try AssertResultFailed(result)
        
        if case .itemNotFound = error {
            XCTFail("Wrong error type \(error)")
        }
    }
    
    func testLoadFailIfBroken() async throws {
        
        let sut = createSUT()

        let trackId = UUID()
        
        let expectedSubtitles = Subtitles(sentences: [
            .init(startTime: 0, duration: 10, text: "Test")
        ])
        
        sut.subtitlesParser.resolve = { text in
            expectedSubtitles
        }
        
        let result = await sut.useCase.load(for: trackId, language: anyLanguage())
        let loadedSubtitles = try AssertResultSucceded(result)
        
        XCTAssertEqual(loadedSubtitles, expectedSubtitles)
    }
}

