//
//  SubtitlesPresenterViewModelTests.swift
//  LyraPlayTests
//
//  Created by Azat Kaiumov on 10.07.22.
//

import Foundation
import XCTest
import LyraPlay

class SubtitlesPresenterViewModelTests: XCTestCase {

    typealias SUT = (
        presenterViewModel: SubtitlesPresenterViewModel,
        loadSubtitlesUseCase: LoadSubtitlesUseCaseMock
    )
    
    func createSUT(mediaFileId: UUID, language: String) -> SUT {
        
        let loadSubtitlesUseCase = LoadSubtitlesUseCaseMock()
        
        let presenterViewModel = DefaultSubtitlesPresenterViewModel(
            mediaFileId: mediaFileId,
            language: language,
            loadSubtitlesUseCase: loadSubtitlesUseCase
        )
        detectMemoryLeak(instance: presenterViewModel)
        
        return (
            presenterViewModel,
            loadSubtitlesUseCase
        )
    }
    
    func anyLanguage() -> String {
        return "English"
    }
        
    func testLoadNotExistingSubtitles() async throws {
        
        let mediaFileId = UUID()
        let loadingSequence = self.expectSequence([false, true])
        
        let sut = createSUT(mediaFileId, language: anyLanguage())
        
        sut.loadSubtitlesUseCase.resolveLoad = { _, _ in .failure(.itemNotFound) }
        
        loadingSequence.observe(sut.presenterViewModel.isLoading)
        
        await sut.viewModel.load()
        
        loadingSequence.wait(timeout: 3, enforceOrder: true)
    }
}

// MARK: - Mocks

final class LoadSubtitlesUseCaseMock: LoadSubtitlesUseCase {

    typealias LoadSubtitlesCallback = (_ mediaFileId: UUID, _ language: String) async -> Result<Subtitles, LoadSubtitlesUseCaseError>
    
    public var resolveLoad: LoadSubtitlesCallback? = nil
    
    func load(for mediaFileId: UUID, language: String) async -> Result<Subtitles, LoadSubtitlesUseCaseError> {
        
        guard let resolveLoad = resolveLoad else {
            fatalError("Not implemented")
        }
        
        return await resolveLoad(mediaFileId, language)
    }
}
