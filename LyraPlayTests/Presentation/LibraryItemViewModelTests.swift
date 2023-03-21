//
//  LibraryItemViewModelTests.swift
//  LyraPlayTests
//
//  Created by Azat Kaiumov on 17.09.22.
//

import Foundation
import XCTest
import Mockingbird
import Combine
import LyraPlay

class LibraryItemViewModelTests: XCTestCase {
    
    typealias SUT = (
        viewModel: LibraryItemViewModel,
        delegate: LibraryItemViewModelDelegateMock,
        showMediaInfoUseCase: ShowMediaInfoUseCaseMock,
        playMediaUseCase: PlayMediaWithInfoUseCaseMock,
        playerState: CurrentValueSubject<PlayMediaWithInfoUseCaseState, Never>
    )
    
    func createSUT(mediaId: UUID) async -> SUT {
        
        let delegate = mock(LibraryItemViewModelDelegate.self)
        let showMediaInfoUseCase = mock(ShowMediaInfoUseCase.self)
        let playMediaUseCase = mock(PlayMediaWithInfoUseCase.self)
        
        given(playMediaUseCase.togglePlay())
            .willReturn(.success(()))
        
        given(playMediaUseCase.play(atTime: any()))
            .willReturn(.success(()))
        
        given(await playMediaUseCase.prepare(session: any()))
            .willReturn(.success(()))
        
        let playerState = CurrentValueSubject<PlayMediaWithInfoUseCaseState, Never>(.noActiveSession)
        
        given(playMediaUseCase.state)
            .willReturn(playerState)
        
        
        let viewModel = LibraryItemViewModelImpl(
            trackId: mediaId,
            delegate: delegate,
            showMediaInfoUseCase: showMediaInfoUseCase,
            playMediaUseCase: playMediaUseCase
        )
        detectMemoryLeak(instance: viewModel)
        
        return (
            viewModel,
            delegate,
            showMediaInfoUseCase,
            playMediaUseCase,
            playerState
        )
    }
    
    private func givenExistingMedia(sut: SUT, mediaId: UUID) async {
        
        let info = MediaInfo(
            id: mediaId.uuidString,
            coverImage: "".data(using: .utf8)!,
            title: "",
            artist: nil,
            duration: 0
        )
        
        given(await sut.showMediaInfoUseCase.fetchInfo(trackId: mediaId))
            .willReturn(.success(info))
    }
    
    func test_isPlaying__no_playing_audio() async throws {
        
        // Given
        let mediaId = UUID()
        let sut = await createSUT(mediaId: mediaId)
        
        await givenExistingMedia(sut: sut, mediaId: mediaId)
        
        let isPlayingPromise = watch(sut.viewModel.isPlaying)
        
        // When
        await sut.viewModel.load()
        
        // Then
        isPlayingPromise.expect([false])
    }
    
    private func anyMediaInfo(id: String) -> MediaInfo {
        return .init(
            id: id,
            coverImage: "".data(using: .utf8)!,
            title: "",
            artist: nil,
            duration: 0
        )
    }
    
    private func givenUseCasePlayingMedia(sut: SUT, id: UUID) {
        
        let mediaInfo = anyMediaInfo(id: id.uuidString)
        
        sut.playerState.value = .activeSession(
            .init(
                mediaId: id,
                learningLanguage: "",
                nativeLanguage: ""
            ),
            .init(.loaded(.init(.playing), mediaInfo))
        )
    }
    
    func test_isPlaying__playing_same_audio() async throws {
        
        // Given
        let mediaId = UUID()
        let sut = await createSUT(mediaId: mediaId)
        
        givenUseCasePlayingMedia(sut: sut, id: mediaId)
        await givenExistingMedia(sut: sut, mediaId: mediaId)
        
        let isPlayingPromise = watch(sut.viewModel.isPlaying)
        
        // When
        await sut.viewModel.load()
        
        // Then
        isPlayingPromise.expect([true])
    }
    
    func test_isPlaying__playing_different_audio() async throws {
        
        // Given
        let mediaId = UUID()
        let playingMediaId = UUID()
        let sut = await createSUT(mediaId: mediaId)
        
        givenUseCasePlayingMedia(sut: sut, id: playingMediaId)
        await givenExistingMedia(sut: sut, mediaId: mediaId)

        let isPlayingPromise = watch(sut.viewModel.isPlaying)
        
        // When
        await sut.viewModel.load()
        
        // Then
        isPlayingPromise.expect([false])
    }
    
    func test_togglePlay__new_session() async throws {
        
        // Given
        let mediaId = UUID()
        let sut = await createSUT(mediaId: mediaId)
        
        await givenExistingMedia(sut: sut, mediaId: mediaId)
        await sut.viewModel.load()
        
        // When
        let _ = await sut.viewModel.togglePlay()
        
        // Then
        verify(sut.playMediaUseCase.togglePlay())
            .wasCalled(1)
    }
    
    func test_togglePlay__existing_session() async throws {
        
        // Given
        let mediaId = UUID()
        let sut = await createSUT(mediaId: mediaId)
        
        await givenExistingMedia(sut: sut, mediaId: mediaId)
        givenUseCasePlayingMedia(sut: sut, id: mediaId)
        
        await sut.viewModel.load()
        
        // When
        let _ = await sut.viewModel.togglePlay()
        
        // Then
        verify(sut.playMediaUseCase.togglePlay())
            .wasCalled(1)
    }
    
    func test_togglePlay__existing_session_different_media() async throws {
        
        // Given
        let mediaId = UUID()
        let secondMediaId = UUID()
        
        let sut = await createSUT(mediaId: mediaId)
        
        await givenExistingMedia(sut: sut, mediaId: mediaId)
        givenUseCasePlayingMedia(sut: sut, id: secondMediaId)
        
        await sut.viewModel.load()
        
        // When
        let _ = await sut.viewModel.togglePlay()
        
        // Then
        verify(await sut.playMediaUseCase.prepare(session: any()))
            .wasCalled(1)
        verify(sut.playMediaUseCase.togglePlay())
            .wasCalled(1)
    }
}
