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
        
        let subtitlesRepository = SubtitlesRepositoryMock()
        let subtitlesFiles = FilesRepositoryMock()
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
    
    func testLoadingFailIfSubtitlesDoesntExist() async throws {
        
        let sut = createSUT()

        let trackId = UUID()
        
        
        let result = await sut.useCase.load(for: trackId, language: anyLanguage())
        let error = try AssertResultFailed(result)
        
        guard case .itemNotFound = error else {
            XCTFail("Wrong error type \(error)")
            return
        }
    }
    
    func testLoadingFailIfBroken() async throws {

        let sut = createSUT()

        let trackId = UUID()

        let _ = await sut.subtitlesRepository.put(
            info: .init(
                mediaFileId: trackId,
                language: anyLanguage(),
                file: "test"
            )
        )
        
        let bundle = Bundle(for: type(of: self ))
        let url = bundle.url(forResource: "test_music_with_tags", withExtension: "mp3")!
        
        let brokenData = try! Data(contentsOf: url)
        
        let _ = await sut.subtitlesFiles.putFile(name: "test", data: brokenData)

        sut.subtitlesParser.resolve = { text in
            return .failure(.internalError(nil))
        }

        let result = await sut.useCase.load(for: trackId, language: anyLanguage())
        let error = try AssertResultFailed(result)

        guard case .internalError = error else {
            XCTFail("Wrong error type \(error)")
            return
        }
    }
    
    func testLoading() async throws {

        let sut = createSUT()

        let trackId = UUID()

        let expectedSubtitles = Subtitles(sentences: [
            .init(startTime: 0, duration: 0, text: .notSynced(text: "Test"))
        ])

        let _ = await sut.subtitlesRepository.put(
            info: .init(
                mediaFileId: trackId,
                language: anyLanguage(),
                file: "test"
            )
        )
        
        let _ = await sut.subtitlesFiles.putFile(name: "test", data: Data())
        sut.subtitlesParser.resolve = { text in .success(expectedSubtitles) }

        let result = await sut.useCase.load(for: trackId, language: anyLanguage())
        let loadedSubtitles = try AssertResultSucceded(result)

        XCTAssertEqual(loadedSubtitles, expectedSubtitles)
    }
}

