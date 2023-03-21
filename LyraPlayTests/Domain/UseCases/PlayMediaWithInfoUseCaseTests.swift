//
//  PlayMediaWithInfoUseCaseTests.swift
//  LyraPlayTests
//
//  Created by Azat Kaiumov on 30.09.22.
//

import Foundation
import XCTest
import Mockingbird
import Combine

import LyraPlay

class PlayMediaWithInfoUseCaseTests: XCTestCase {
    
    typealias SUT = (
        useCase: PlayMediaWithInfoUseCase,
        playMediaWithTranslationsUseCaseFactory: PlayMediaWithTranslationsUseCaseFactoryMock,
        playMediaWithTranslationsUseCase: PlayMediaWithTranslationsUseCaseMock,
        showMediaInfoUseCaseFactory: ShowMediaInfoUseCaseFactoryMock,
        showMediaInfoUseCase: ShowMediaInfoUseCaseMock,
        playMediaWithTranslationsUseCaseState: CurrentValueSubject<PlayMediaWithTranslationsUseCaseState, Never>,
        subtitlesState: CurrentValueSubject<SubtitlesState?, Never>,
        pronounceTranslationsState: CurrentValueSubject<PronounceTranslationsUseCaseState, Never>
    )
    
    func createSUT() -> SUT {
    
        let playMediaWithTranslationsUseCaseState = CurrentValueSubject<PlayMediaWithTranslationsUseCaseState, Never>(.noActiveSession)
        
        let playMediaWithTranslationsUseCase = mock(PlayMediaWithTranslationsUseCase.self)
        let playMediaWithTranslationsUseCaseFactory = mock(PlayMediaWithTranslationsUseCaseFactory.self)
        
        given(playMediaWithTranslationsUseCaseFactory.make())
            .willReturn(playMediaWithTranslationsUseCase)
        
        given(playMediaWithTranslationsUseCase.state)
            .willReturn(playMediaWithTranslationsUseCaseState)
        
        let subtitlesState = CurrentValueSubject<SubtitlesState?, Never>(nil)
        
        given(playMediaWithTranslationsUseCase.subtitlesState)
            .willReturn(subtitlesState)
        
        let pronounceTranslationsState = CurrentValueSubject<PronounceTranslationsUseCaseState, Never>(.stopped)
        
        given(playMediaWithTranslationsUseCase.pronounceTranslationsState)
            .willReturn(pronounceTranslationsState)
        
        let showMediaInfoUseCase = mock(ShowMediaInfoUseCase.self)
        let showMediaInfoUseCaseFactory = mock(ShowMediaInfoUseCaseFactory.self)
        
        given(showMediaInfoUseCaseFactory.make())
            .willReturn(showMediaInfoUseCase)
        
        let useCase = PlayMediaWithInfoUseCaseImpl(
            playMediaWithTranslationsUseCaseFactory: playMediaWithTranslationsUseCaseFactory,
            showMediaInfoUseCaseFactory: showMediaInfoUseCaseFactory
        )
        
        detectMemoryLeak(instance: useCase)
        
        releaseMocks(
            playMediaWithTranslationsUseCaseFactory,
            playMediaWithTranslationsUseCase,
            showMediaInfoUseCaseFactory,
            showMediaInfoUseCase
        )
        
        return (
            useCase,
            playMediaWithTranslationsUseCaseFactory,
            playMediaWithTranslationsUseCase,
            showMediaInfoUseCaseFactory,
            showMediaInfoUseCase,
            playMediaWithTranslationsUseCaseState,
            subtitlesState,
            pronounceTranslationsState
        )
    }
    
    func anyMediaInfo(id: String) -> MediaInfo {
        
        return .init(
            id: id,
            coverImage: "".data(using: .utf8)!,
            title: "",
            artist: nil,
            duration: 0
        )
    }
    
    func test_prepare() async throws {
     
        let sut = createSUT()
        
        // Given
        let mediaId = UUID()
        let mediaInfo = anyMediaInfo(id: mediaId.uuidString)
        
        given(await sut.showMediaInfoUseCase.fetchInfo(trackId: mediaId))
            .willReturn(.success(mediaInfo))
        
        let session = PlayMediaWithInfoSession(
            mediaId: mediaId,
            learningLanguage: "",
            nativeLanguage: ""
        )
        
        let statePromise = watch(sut.useCase.state)
        
        let playMediaWithTranslationsUseCaseState = sut.playMediaWithTranslationsUseCaseState
        let playMediaWithTranslationSession = PlayMediaWithTranslationsSession(mediaId: mediaId, learningLanguage: "", nativeLanguage: "")
        
        given(await sut.playMediaWithTranslationsUseCase.prepare(session: playMediaWithTranslationSession))
            .will({ [weak playMediaWithTranslationsUseCaseState] session in
                
                playMediaWithTranslationsUseCaseState?.value = .activeSession(playMediaWithTranslationSession, .loaded)
                return .success(())
            })
        
        // When
        let result = await sut.useCase.prepare(session: session)
        
        // Then
        try AssertResultSucceded(result)
        
        statePromise.expect(match: [
        
            StateMatcher()
        ])
        statePromise.expect([
            .noActiveSession,
            .activeSession(session, .init(.loading)),
            .activeSession(session, .init(.loaded(.init(.initial), mediaInfo))),
        ])
    }
}

struct StateMatcher: ValueMatcher {
    
    init(state: )
    
    func match(capturedValue: CapturedValue) -> Bool {
        <#code#>
    }
}
