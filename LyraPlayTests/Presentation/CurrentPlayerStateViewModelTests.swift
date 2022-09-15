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
        playMediaUseCase: PlayMediaWithTranslationsUseCaseMock,
        showMediaInfoUseCase: ShowMediaInfoUseCaseMock,
        playerState: PublisherWithSession<PlayMediaWithTranslationsUseCaseState, Never>
    )

    // MARK: - Methods

    func createSUT() -> SUT {

        let delegate = mock(CurrentPlayerStateViewModelDelegate.self)

        let playMediaUseCase = mock(PlayMediaWithTranslationsUseCase.self)
        
        let state = PublisherWithSession<PlayMediaWithTranslationsUseCaseState, Never>(.initial)
        
        given(playMediaUseCase.state)
            .willReturn(state)

        let showMediaInfoUseCase = mock(ShowMediaInfoUseCase.self)

        let viewModel = CurrentPlayerStateViewModelImpl(
            delegate: delegate,
            playMediaUseCase: playMediaUseCase,
            showMediaInfoUseCase: showMediaInfoUseCase
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
    
    func test_change_state__playing() {
        
        // Given
        let sut = createSUT()
        
        // When
        sut.playerState.value = .playing(
            session: .init(mediaId: UUID(), learningLanguage: "", nativeLanguage: ""),
            subtitlesState: nil
        )
        
        // Then
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
    
    func test_change_state__paused() {
        
        // Given
        let sut = createSUT()
        
        // When
        sut.playerState.value = .paused(
            session: .init(mediaId: UUID(), learningLanguage: "", nativeLanguage: ""),
            subtitlesState: nil,
            time: 10
        )
        
        // Then
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
    
    func test_change_state__initial() {
        
        // Given
        let sut = createSUT()
        
        // When
        sut.playerState.value = .initial
        
        // Then
        let state = sut.viewModel.state.value
        
        guard case .notActive = state else {
            
            XCTFail("Wrong state \(state)")
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

        // When
        let result = sut.viewModel.togglePlay()

        // Then
    }
}
