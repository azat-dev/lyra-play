//
//  CurrentPlayerStateDetailsViewModelTests.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 30.09.2022.
//

import Foundation
import XCTest
import Mockingbird
import Combine
import LyraPlay

class CurrentPlayerStateDetailsViewModelTests: XCTestCase {

    typealias SUT = (
        viewModel: CurrentPlayerStateDetailsViewModel,
        delegate: CurrentPlayerStateDetailsViewModelDelegateMock,
        playMediaUseCase: PlayMediaWithInfoUseCaseMock,
        playerState: CurrentValueSubject<PlayMediaWithInfoUseCaseState, Never>,
        subtitlesPresenterViewModel: SubtitlesPresenterViewModel,
        subtitlesState: CurrentValueSubject<SubtitlesState?, Never>
    )

    // MARK: - Methods

    func createSUT() -> SUT {

        let delegate = mock(CurrentPlayerStateDetailsViewModelDelegate.self)

        let playMediaUseCase = mock(PlayMediaWithInfoUseCase.self)
        
        let playerState = CurrentValueSubject<PlayMediaWithInfoUseCaseState, Never>(.noActiveSession)
        
        given(playMediaUseCase.state)
            .willReturn(playerState)
        

        let subtitlesState = CurrentValueSubject<SubtitlesState?, Never>(nil)
        
        let subtitlesPresenterViewModelFactory = mock(SubtitlesPresenterViewModelFactory.self)
        let subtitlesPresenterViewModel = mock(SubtitlesPresenterViewModel.self)
        
        given(subtitlesPresenterViewModelFactory.make(subtitles: any()))
            .willReturn(subtitlesPresenterViewModel)
        
        given(playMediaUseCase.subtitlesState)
            .willReturn(subtitlesState)

        let viewModel = CurrentPlayerStateDetailsViewModelImpl(
            delegate: delegate,
            playMediaUseCase: playMediaUseCase,
            subtitlesPresenterViewModelFactory: subtitlesPresenterViewModelFactory
        )

        detectMemoryLeak(instance: viewModel)

        return (
            viewModel,
            delegate,
            playMediaUseCase,
            playerState,
            subtitlesPresenterViewModel,
            subtitlesState
        )
    }
    
    private func anyMediaInfo() -> MediaInfo {
        
        return .init(
            id: UUID().uuidString,
            coverImage: "".data(using: .utf8)!,
            title: "title",
            artist: "artist",
            duration: 10
        )
    }

    func test_togglePlay() async throws {

        // Given
        let sut = createSUT()

        let statePromise = watch(sut.viewModel.state)
        let mediaInfo = anyMediaInfo()
        
        let session = PlayMediaWithInfoSession(
            mediaId: UUID(uuidString: mediaInfo.id)!,
            learningLanguage: "",
            nativeLanguage: ""
        )
        
        given(sut.playMediaUseCase.togglePlay())
            .willReturn(.success(()))
        
        // When
        sut.viewModel.togglePlay()
        sut.viewModel.togglePlay()
        
        sut.playerState.value = .activeSession(session, .loading)
        sut.playerState.value = .activeSession(session, .loaded(.playing, mediaInfo))
        
        sut.playerState.value = .activeSession(session, .loaded(.paused, mediaInfo))

        // Then
        verify(sut.playMediaUseCase.togglePlay())
            .wasCalled(2)
        
        statePromise.expect(match: [
            .caseName(.notActive),
            .caseName(.loading),
            .activeData(
                .init(
                    title: mediaInfo.title,
                    subtitle: mediaInfo.artist ?? "",
                    coverImage: mediaInfo.coverImage,
                    isPlaying: true
                )
            
            ),
            .activeData(
                .init(
                    title: mediaInfo.title,
                    subtitle: mediaInfo.artist ?? "",
                    coverImage: mediaInfo.coverImage,
                    isPlaying: false
                )
            )
        ] as [Match])
    }
    
    func test_update_subtitles() async throws {

        // Given
        let sut = createSUT()

        let subtitles = Subtitles(
            duration: 19,
            sentences: [
                .anySentence(at: 0),
                .anySentence(at: 1)
            ]
        )
        
        let expectedSubtitlesIndexes = [0, 1, 3]
        
        sut.subtitlesState.value = .init(position: nil, subtitles: subtitles)
        sut.playerState.value = .activeSession(
            anySession(),
            .loaded(.initial, anyMediaInfo())
        )
        
        
        // When
        expectedSubtitlesIndexes.forEach({ index in
            
            sut.subtitlesState.value = .init(
                position: .sentence(index),
                subtitles: subtitles
            )
        })
        
        // Then
        eventually {
            inOrder {
                expectedSubtitlesIndexes.forEach { sentenceIndex in
                    verify(sut.subtitlesPresenterViewModel.update(position: .sentence(sentenceIndex)))
                        .wasCalled(1)
                }
            }
        }
        
        await waitForExpectations(timeout: 1)
    }

    func test_dispose() async throws {

        // Given
        let sut = createSUT()

        // When
        sut.viewModel.dispose()

        // Then
        verify(sut.delegate.currentPlayerStateDetailsViewModelDidDispose())
            .wasCalled(1)
    }
    
    private func anySession() -> PlayMediaWithInfoSession {
        
        return .init(
            mediaId: UUID(),
            learningLanguage: "English",
            nativeLanguage: "French"
        )
    }
}

// MARK: - Helpers

fileprivate enum Match: ValueMatcher {
    
    typealias CapturedValue = CurrentPlayerStateDetailsViewModelState
    
    case caseName(CurrentPlayerStateDetailsViewModelState)
    case activeData(CurrentPlayerStateDetailsViewModelPresentationPartial)
    
    // MARK: - Methods
    
    private func matchCaseName(
        _ expectedValue: CurrentPlayerStateDetailsViewModelState,
        _ capturedValue: CapturedValue
    ) -> Bool {
        
        switch (expectedValue, capturedValue) {

        case (.loading, .loading):
            return true

        case (.notActive, .notActive):
            return true

        case (.active, .active):
            return true

        case (_, _):
            return false
        }
    }
    
    private func matchActiveData(
        _ expectedValue: CurrentPlayerStateDetailsViewModelPresentationPartial,
        _ capturedValue: CapturedValue
    ) -> Bool {
        
        guard case .active(let data) = capturedValue else {
            return false
        }
        
        let capturedData = CurrentPlayerStateDetailsViewModelPresentationPartial(
            title: data.title,
            subtitle: data.subtitle,
            coverImage: data.coverImage,
            isPlaying: data.isPlaying
        )

        return expectedValue == capturedData
    }
    
    public func match(capturedValue: CapturedValue) -> Bool {
        
        switch self {
            
        case .caseName(let expectedValue):
            return matchCaseName(expectedValue, capturedValue)
            
        case .activeData(let expectedValue):
            return matchActiveData(expectedValue, capturedValue)
        }
    }
}

fileprivate struct CurrentPlayerStateDetailsViewModelPresentationPartial: Equatable {

    var title: String
    var subtitle: String
    var coverImage: Data?
    var isPlaying: Bool
}
