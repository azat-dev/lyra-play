//
//  CurrentPlayerStateViewModelTests.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 15.09.2022.
//

import Foundation
import XCTest
import Mockingbird
import LyraPlay

class CurrentPlayerStateViewModelTests: XCTestCase {

    typealias SUT = (
        viewModel: CurrentPlayerStateViewModel,
        delegate: CurrentPlayerStateViewModelDelegateMock,
        playMediaUseCase: PlayMediaWithInfoUseCaseMock,
        showMediaInfoUseCase: ShowMediaInfoUseCaseMock,
        playerState: PublisherWithSession<PlayMediaWithInfoUseCaseState, Never>
    )

    // MARK: - Methods

    func createSUT() -> SUT {

        let delegate = mock(CurrentPlayerStateViewModelDelegate.self)

        let showMediaInfoUseCase = mock(ShowMediaInfoUseCase.self)
        let showMediaInfoUseCaseFactory = mock(ShowMediaInfoUseCaseFactory.self)
        
        given(showMediaInfoUseCaseFactory.create())
            .willReturn(showMediaInfoUseCase)
        
        
        let playMediaUseCase = mock(PlayMediaWithInfoUseCase.self)
        
        let state = PublisherWithSession<PlayMediaWithInfoUseCaseState, Never>(.noActiveSession)
        
        given(playMediaUseCase.state)
            .willReturn(state)

        
        let viewModel = CurrentPlayerStateViewModelImpl(
            delegate: delegate,
            playMediaUseCase: playMediaUseCase
        )

        detectMemoryLeak(instance: viewModel)

        return (
            viewModel: viewModel,
            delegate: delegate,
            playMediaUseCase: playMediaUseCase,
            showMediaInfoUseCase: showMediaInfoUseCase,
            state
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
    
    func test_change_state__playing() async throws {
        
        let sut = createSUT()

        // Given
        let mediaId = UUID()
        let mediaInfo = anyMediaInfo(id: mediaId.uuidString)
        
        given(await sut.showMediaInfoUseCase.fetchInfo(trackId: mediaId))
            .willReturn(.success(mediaInfo))
        
        // When
        sut.playerState.value = .activeSession(
            .init(mediaId: mediaId, learningLanguage: "", nativeLanguage: ""),
            .loaded(.playing, nil, mediaInfo)
        )

        // Then
        for await state in sut.viewModel.state.values {
            guard case .loading = state else {
                break
            }
        }

        let state = sut.viewModel.state.value
        
        guard case .active(_, let playerState) = state else {
            
            XCTFail("Wrong state \(state)")
            return
        }
        
        guard case .playing = playerState else {
            
            XCTFail("Wrong state \(playerState)")
            return
        }
    }
    
    func test_change_state__paused() async throws {

        let sut = createSUT()

        // Given
        let mediaId = UUID()
        let mediaInfo = anyMediaInfo(id: mediaId.uuidString)
        
        given(await sut.showMediaInfoUseCase.fetchInfo(trackId: mediaId))
            .willReturn(.success(mediaInfo))
        
        // When
        sut.playerState.value = .activeSession(
            .init(mediaId: mediaId, learningLanguage: "", nativeLanguage: ""),
            .loaded(.paused(time: 10), nil, mediaInfo)
        )

        // Then
        for await state in sut.viewModel.state.values {
            guard case .loading = state else {
                break
            }
        }

        let state = sut.viewModel.state.value
        
        guard case .active(_, let playerState) = state else {
            
            XCTFail("Wrong state \(state)")
            return
        }
        
        guard case .paused = playerState else {
            
            XCTFail("Wrong state \(playerState)")
            return
        }
    }
    
    func test_open() async throws {

        // Given
        let sut = createSUT()
        given(sut.delegate.currentPlayerStateViewModelDidOpen())
            .willReturn(())
        
        // When
        sut.viewModel.open()

        // Then
        verify(sut.delegate.currentPlayerStateViewModelDidOpen())
            .wasCalled()
    }

    func test_togglePlay() async throws {

        // Given
        let sut = createSUT()

        given(sut.playMediaUseCase.togglePlay())
            .willReturn(.success(()))

        // When
        sut.viewModel.togglePlay()

        // Then
        verify(sut.playMediaUseCase.togglePlay())
            .wasCalled(1)
    }
}
