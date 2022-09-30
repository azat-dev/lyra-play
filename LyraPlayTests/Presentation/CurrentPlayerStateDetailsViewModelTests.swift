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
        playMediaUseCase: PlayMediaWithInfoUseCaseMock
    )

    // MARK: - Methods

    func createSUT() -> SUT {

        let delegate = mock(CurrentPlayerStateDetailsViewModelDelegate.self)

        let playMediaUseCase = mock(PlayMediaWithInfoUseCase.self)

        let viewModel = CurrentPlayerStateDetailsViewModelImpl(
            delegate: delegate,
            playMediaUseCase: playMediaUseCase
        )

        detectMemoryLeak(instance: viewModel)

        return (
            viewModel: viewModel,
            delegate: delegate,
            playMediaUseCase: playMediaUseCase
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
        
        // When
        sut.viewModel.togglePlay()
        sut.viewModel.togglePlay()

        // Then
        statePromise.expect([
            .notActive,
            .loading,
            .active(
                data: .init(
                    title: mediaInfo.title,
                    subtitle: mediaInfo.artist ?? "",
                    coverImage: mediaInfo.coverImage,
                    isPlaying: true
                )
            ),
            .active(
                data: .init(
                    title: mediaInfo.title,
                    subtitle: mediaInfo.artist ?? "",
                    coverImage: mediaInfo.coverImage,
                    isPlaying: false
                )
            )
        ])
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
