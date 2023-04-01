//
//  CurrentPlayerStateViewModelTests.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 15.09.2022.
//

import Foundation
import XCTest
import Mockingbird
import Combine
import LyraPlay

class CurrentPlayerStateViewModelTests: XCTestCase {

    typealias SUT = (
        viewModel: CurrentPlayerStateViewModel,
        delegate: CurrentPlayerStateViewModelDelegateMock,
        playMediaUseCase: PlayMediaWithInfoUseCaseMock,
        showMediaInfoUseCase: ShowMediaInfoUseCaseMock,
        playerState: CurrentValueSubject<PlayMediaWithInfoUseCaseState, Never>
    )

    // MARK: - Methods

    func createSUT() -> SUT {

        let delegate = mock(CurrentPlayerStateViewModelDelegate.self)

        let showMediaInfoUseCase = mock(ShowMediaInfoUseCase.self)
        let showMediaInfoUseCaseFactory = mock(ShowMediaInfoUseCaseFactory.self)
        
        given(showMediaInfoUseCaseFactory.make())
            .willReturn(showMediaInfoUseCase)
        
        let playMediaUseCase = mock(PlayMediaWithInfoUseCase.self)
        
        let state = CurrentValueSubject<PlayMediaWithInfoUseCaseState, Never>(.noActiveSession)
        
        given(playMediaUseCase.state)
            .willReturn(state)
        
        let getLastPlayedMediaUseCaseFactory = mock(GetLastPlayedMediaUseCaseFactory.self)
        
        let viewModel = CurrentPlayerStateViewModelImpl(
            delegate: delegate,
            playMediaUseCase: playMediaUseCase,
            getLastPlayedMediaUseCaseFactory: getLastPlayedMediaUseCaseFactory,
            showMediaInfoUseCaseFactory: showMediaInfoUseCaseFactory
        )

        detectMemoryLeak(instance: viewModel)
        
        releaseMocks(
            delegate,
            showMediaInfoUseCase,
            showMediaInfoUseCaseFactory,
            playMediaUseCase,
            getLastPlayedMediaUseCaseFactory
        )

        return (
            viewModel: viewModel,
            delegate: delegate,
            playMediaUseCase: playMediaUseCase,
            showMediaInfoUseCase: showMediaInfoUseCase,
            state
        )
    }
    
    func anyMediaInfo(id: UUID) -> MediaInfo {
        
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
        let mediaInfo = anyMediaInfo(id: mediaId)
        
        given(await sut.showMediaInfoUseCase.fetchInfo(trackId: mediaId))
            .willReturn(.success(mediaInfo))
        
        // When
        sut.playerState.value = .activeSession(
            .init(mediaId: mediaId, learningLanguage: "", nativeLanguage: ""),
            .init(.loaded(.init(.playing), mediaInfo))
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
        
        guard case .playing = playerState.value else {
            XCTFail("Wrong state \(playerState)")
            return
        }
    }
    
    func test_change_state__paused() async throws {

        let sut = createSUT()

        // Given
        let mediaId = UUID()
        let mediaInfo = anyMediaInfo(id: mediaId)
        
        given(await sut.showMediaInfoUseCase.fetchInfo(trackId: mediaId))
            .willReturn(.success(mediaInfo))
        
        // When
        sut.playerState.value = .activeSession(
            .init(mediaId: mediaId, learningLanguage: "", nativeLanguage: ""),
            .init(.loaded(.init(.paused), mediaInfo))
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
        
        guard case .paused = playerState.value else {
            
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
