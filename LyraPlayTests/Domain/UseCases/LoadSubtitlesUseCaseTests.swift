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
        subtitlesRepository: SubtitlesRepositoryMockDeprecated,
        subtitlesFiles: FilesRepositoryMockDeprecated,
        subtitlesParser: SubtitlesParserMock
    )

    func createSUT() -> SUT {
        
        let subtitlesRepository = SubtitlesRepositoryMockDeprecated()
        let subtitlesFiles = FilesRepositoryMockDeprecated()
        let subtitlesParser = SubtitlesParserMock()
        
        let useCase = LoadSubtitlesUseCaseImpl(
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

        sut.subtitlesParser.resolve = { text, _ in
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

        let expectedSubtitles = Subtitles(
            duration: 0.1,
            sentences: [
                .init(startTime: 0, duration: nil, text: "Test", components: [])
            ]
        )

        let _ = await sut.subtitlesRepository.put(
            info: .init(
                mediaFileId: trackId,
                language: anyLanguage(),
                file: "test"
            )
        )
        
        let _ = await sut.subtitlesFiles.putFile(name: "test", data: Data())
        sut.subtitlesParser.resolve = { text, _ in .success(expectedSubtitles) }

        let result = await sut.useCase.load(for: trackId, language: anyLanguage())
        let loadedSubtitles = try AssertResultSucceded(result)

        XCTAssertEqual(loadedSubtitles, expectedSubtitles)
    }
}

