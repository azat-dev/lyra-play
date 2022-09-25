//
//  PlayMediaUseCaseTests.swift
//  LyraPlayTests
//
//  Created by Azat Kaiumov on 10.08.2022.
//

import XCTest
import Combine
import LyraPlay

class PlayMediaUseCaseStateEquatable: XCTestCase {
    
    // MARK: - Helpers
    
    typealias SUT = (
        useCase: PlayMediaUseCase,
        audioPlayer: AudioPlayerMock,
        loadTrackUseCase: LoadTrackUseCaseMock
    )
    
    func createSUT() -> SUT {
        
        let audioPlayer = AudioPlayerMock()
        let loadTrackUseCase = LoadTrackUseCaseMock()
        
        let useCase = PlayMediaUseCaseImpl(
            audioPlayer: audioPlayer,
            loadTrackUseCase: loadTrackUseCase
        )
        detectMemoryLeak(instance: useCase)
        
        return (
            useCase,
            audioPlayer,
            loadTrackUseCase
        )
    }
    
    private func waitForState(_ sut: SUT, where whereState: (PlayMediaUseCaseState) -> Bool) async throws {
        
        for try await state in sut.useCase.state.values {
            if whereState(state) {
                return
            }
        }
        
        throw NSError(domain: "Can't achive state", code: 0)
    }
    
    private func givenMediaExists(_ sut: SUT, mediaId: UUID) {
        
        sut.loadTrackUseCase.tracks[mediaId] = mediaId.uuidString.data(using: .utf8)
    }
    
    private func givenPrepared(_ sut: SUT, mediaId: UUID) async throws {
        
        givenMediaExists(sut, mediaId: mediaId)
        
        let result = await sut.useCase.prepare(mediaId: mediaId)
        try AssertResultSucceded(result)
        
        try await waitForState(sut, where: { $0 == .loaded(mediaId: mediaId) })
    }
    
    private func givenPlayingState(_ sut: SUT, mediaId: UUID) async throws {
        
        let result = sut.useCase.play()
        try AssertResultSucceded(result)
        
        try await waitForState(sut, where: { $0 == .playing(mediaId: mediaId) })
    }
    
    private func givenPaused(_ sut: SUT, mediaId: UUID) async throws {
        
        let result = sut.useCase.pause()
        try AssertResultSucceded(result)
        
        try await waitForState(sut, where: { state in
            
            if case .paused = state {
                return true
            }
            
            return false
        })
    }
    
    // MARK: - Test Methods
    
    func test_prepare__not_existing_media() async throws {
        
        // Given
        let sut = createSUT()
        
        // When
        let result = await sut.useCase.prepare(mediaId: UUID())
        
        // Then
        let error = try AssertResultFailed(result)
        
        guard case .trackNotFound = error else {
            XCTFail("Wrong error type \(error)")
            return
        }
    }
    
    func test_prepare__existing_media() async throws {
        
        let sut = createSUT()
        
        // Given
        let mediaId = UUID()
        givenMediaExists(sut, mediaId: mediaId)
        
        let statePromise = watch(sut.useCase.state, mapper: { _ in ExpectedState(from: sut) })
        
        // When
        let result = await sut.useCase.prepare(mediaId: mediaId)
        
        // Then
        try AssertResultSucceded(result)
        
        statePromise.expect([
            .init(.initial, audioPlayer: .initial),
            .init(.loading(mediaId: mediaId), audioPlayer: .initial),
            .init(.loaded(mediaId: mediaId), audioPlayer: .loaded(session: .init(fileId: mediaId.uuidString))),
        ])
    }
    
    func test_play__existing_media() async throws {
        
        let sut = createSUT()
        let mediaId = UUID()
        
        // Given
        try await givenPrepared(sut, mediaId: mediaId)
        let result = sut.useCase.play()
        
        // Then
        try AssertResultSucceded(result)
        AssertEqualReadable(
            ExpectedState(from: sut),
            .init(
                .playing(mediaId: mediaId),
                audioPlayer: .playing(session: .init(fileId: mediaId.uuidString))
            )
        )
    }
    
    func test_pause__not_active_media() async throws {
        
        let sut = createSUT()
        
        // Given
        
        // When
        let result = sut.useCase.pause()
        let error = try AssertResultFailed(result)
        
        // Then
        guard case .noActiveTrack = error else {
            XCTFail("Wrong error type \(result)")
            return
        }
    }
    
    func test_pause__active_media() async throws {
        
        let sut = createSUT()
        let mediaId = UUID()
        
        // Given
        try await givenPrepared(sut, mediaId: mediaId)
        try await givenPlayingState(sut, mediaId: mediaId)
        
        // When
        let result = sut.useCase.pause()
        try AssertResultSucceded(result)
        
        // Then
        AssertEqualReadable(
            ExpectedState(from: sut),
            .init(
                .paused(mediaId: mediaId, time: 0),
                audioPlayer: .paused(session: .init(fileId: mediaId.uuidString), time: 0)
            )
        )
    }
    
    func test_play__paused_media() async throws {
        
        let sut = createSUT()
        let mediaId = UUID()
        
        // Given
        try await givenPrepared(sut, mediaId: mediaId)
        try await givenPlayingState(sut, mediaId: mediaId)
        try await givenPaused(sut, mediaId: mediaId)
        
        // When
        let result = sut.useCase.play()
        try AssertResultSucceded(result)
        
        // Then
        AssertEqualReadable(
            ExpectedState(from: sut),
            .init(
                .playing(mediaId: mediaId),
                audioPlayer: .playing(session: .init(fileId: mediaId.uuidString))
            )
        )
    }
    
    func test_change_active_media() async throws {
        
        let sut = createSUT()
        let mediaId1 = UUID()
        let mediaId2 = UUID()
        
        // Given
        try await givenPrepared(sut, mediaId: mediaId1)
        try await givenPlayingState(sut, mediaId: mediaId1)
        try await givenPrepared(sut, mediaId: mediaId2)
        
        // When
        let result = sut.useCase.play()
        try AssertResultSucceded(result)
        
        // Then
        AssertEqualReadable(
            ExpectedState(from: sut),
            .init(
                .playing(mediaId: mediaId2),
                audioPlayer: .playing(session: .init(fileId: mediaId2.uuidString))
            )
        )
    }
}

// MARK: - Helpers

extension PlayMediaUseCaseStateEquatable {
    
    struct ExpectedState: Equatable {
        
        var useCaseState: PlayMediaUseCaseState
        var audioPlayerState: AudioPlayerState
        
        
        public init(_ useCaseState: PlayMediaUseCaseState, audioPlayer: AudioPlayerState) {
            
            self.useCaseState = useCaseState
            self.audioPlayerState = audioPlayer
        }
        
        public init(from sut: SUT) {
            
            self.useCaseState = sut.useCase.state.value
            self.audioPlayerState = sut.audioPlayer.state.value
        }
    }
}
