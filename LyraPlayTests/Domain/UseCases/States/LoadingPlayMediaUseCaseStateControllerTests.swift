//
//  LoadingPlayMediaUseCaseStateControllerTests.swift
//  LyraPlayTests
//
//  Created by Azat Kaiumov on 14.02.23.
//

import Foundation
import XCTest
import Mockingbird

import LyraPlay

class LoadingPlayMediaUseCaseStateControllerTests: XCTestCase {
    
    typealias SUT = (
        controller: LoadingPlayMediaUseCaseStateController,
        loadTrackUseCase: LoadTrackUseCaseMock,
        delegate: PlayMediaUseCaseStateControllerDelegateMock,
        audioPlayer: AudioPlayerMock
    )
    
    func createSUT(
        mediaId: UUID,
        loadTrackUseCase: LoadTrackUseCaseMock,
        audioPlayer: AudioPlayerMock
    ) -> SUT {

        let loadTrackUseCaseFactory = mock(LoadTrackUseCaseFactory.self)
        
        given(loadTrackUseCaseFactory.make())
            .willReturn(loadTrackUseCase)
        
        let audioPlayerFactory = mock(AudioPlayerFactory.self)
        
        given(audioPlayerFactory.make())
            .willReturn(audioPlayer)
        
        let delegate = mock(PlayMediaUseCaseStateControllerDelegate.self)
        
        let controller = LoadingPlayMediaUseCaseStateControllerImpl(
            mediaId: mediaId,
            delegate: delegate,
            loadTrackUseCaseFactory: loadTrackUseCaseFactory,
            audioPlayerFactory: audioPlayerFactory
        )
        
        detectMemoryLeak(instance: controller)
        
        return (
            controller,
            loadTrackUseCase,
            delegate,
            audioPlayer
        )
    }
    
    // MARK: - Test Methods
    
    func test_prepare__replace_existing_loading() async throws {

        // Given
        let mediaId1 = UUID()
        let mediaId2 = UUID()
        
        let loadTrackUseCase = mock(LoadTrackUseCase.self)
        
        given(await loadTrackUseCase.load(trackId: mediaId1))
            .willReturn(.success("success".data(using: .utf8)!))
        
        let audioPlayer = mock(AudioPlayer.self)
        
        given(audioPlayer.prepare(fileId: any(), data: any()))
            .willReturn(.success(()))
        
        let sut = createSUT(
            mediaId: mediaId1,
            loadTrackUseCase: loadTrackUseCase,
            audioPlayer: audioPlayer
        )
        
        given(await sut.delegate.load(mediaId: any()))
            .willReturn(.success(()))

        // When
        let result = await sut.controller.prepare(mediaId: mediaId2)
        try AssertResultSucceded(result)

        // Then
        verify(await sut.delegate.load(mediaId: mediaId2))
            .wasCalled(1)
    }
    
    func test_load__success() async throws {

        // Given
        let mediaId = UUID()
        
        let loadTrackUseCase = mock(LoadTrackUseCase.self)
        
        given(await loadTrackUseCase.load(trackId: mediaId))
            .willReturn(.success("success".data(using: .utf8)!))
        
        let audioPlayer = mock(AudioPlayer.self)
        
        given(audioPlayer.prepare(fileId: any(), data: any()))
            .willReturn(.success(()))
        
        let sut = createSUT(
            mediaId: mediaId,
            loadTrackUseCase: loadTrackUseCase,
            audioPlayer: audioPlayer
        )
        
        // When
        let result = await sut.controller.load()

        // Then
        try AssertResultSucceded(result)
        
        verify(sut.delegate.didLoad(mediaId: mediaId, audioPlayer: audioPlayer))
            .wasCalled(1)
    }
    
    func test_load__failed_load() async throws {

        // Given
        let mediaId = UUID()
        
        let loadTrackUseCase = mock(LoadTrackUseCase.self)
        
        given(await loadTrackUseCase.load(trackId: mediaId))
            .willReturn(.failure(.internalError(nil)))
        
        let audioPlayer = mock(AudioPlayer.self)
        
        given(audioPlayer.prepare(fileId: any(), data: any()))
            .willReturn(.success(()))
        
        let sut = createSUT(
            mediaId: mediaId,
            loadTrackUseCase: loadTrackUseCase,
            audioPlayer: audioPlayer
        )
        
        // When
        let result = await sut.controller.load()

        // Then
        try AssertResultSucceded(result)
        
        verify(sut.delegate.didFailLoad(mediaId: mediaId))
            .wasCalled(1)
    }
}
