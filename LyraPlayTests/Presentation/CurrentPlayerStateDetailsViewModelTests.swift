//
//  CurrentPlayerStateDetailsViewModelTests.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 30.09.2022.
//

import Foundation
import XCTest
import Mockingbird
import LyraPlay

class CurrentPlayerStateDetailsViewModelTests: XCTestCase {

    typealias SUT = (
        viewModel: CurrentPlayerStateDetailsViewModel,
        delegate: CurrentPlayerStateDetailsViewModelDelegateMock,
        playMediaUseCase: PlayMediaWithInfoUseCaseMock,
        playerState: PublisherWithSession<PlayMediaWithInfoUseCaseState, Never>
    )

    // MARK: - Methods

    func createSUT() -> SUT {

        let delegate = mock(CurrentPlayerStateDetailsViewModelDelegate.self)

        let playMediaUseCase = mock(PlayMediaWithInfoUseCase.self)
        
        let playerState = PublisherWithSession<PlayMediaWithInfoUseCaseState, Never>(.noActiveSession)
        
        given(playMediaUseCase.state)
            .willReturn(playerState)
        
        let subtitlesPresenterViewModelFactory = mock(SubtitlesPresenterViewModelFactory.self)
        let subtitlesPresenterViewModel = mock(SubtitlesPresenterViewModel.self)
        
        given(subtitlesPresenterViewModelFactory.create(subtitles: any()))
            .willReturn(subtitlesPresenterViewModel)

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
            playerState
        )
    }

    func test_togglePlay() async throws {

        // Given
        let sut = createSUT()

        let statePromise = watch(sut.viewModel.state)
        let mediaInfo = MediaInfo(
            id: UUID().uuidString,
            coverImage: "".data(using: .utf8)!,
            title: "title",
            artist: "artist",
            duration: 10
        )
        
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
        sut.playerState.value = .activeSession(session, .loaded(.playing, nil, mediaInfo))
        sut.playerState.value = .activeSession(session, .loaded(.paused(time: 0), nil, mediaInfo))

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

    func test_dispose() async throws {

        // Given
        let sut = createSUT()

        // When
        sut.viewModel.dispose()

        // Then
        verify(sut.delegate.currentPlayerStateDetailsViewModelDidDispose())
            .wasCalled(1)
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
        
        guard case .active(let rhsData) = capturedValue else {
            return false
        }
        
        let capturedData = CurrentPlayerStateDetailsViewModelPresentationPartial(
            title: rhsData.title,
            subtitle: rhsData.subtitle,
            coverImage: rhsData.coverImage,
            isPlaying: rhsData.isPlaying
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
