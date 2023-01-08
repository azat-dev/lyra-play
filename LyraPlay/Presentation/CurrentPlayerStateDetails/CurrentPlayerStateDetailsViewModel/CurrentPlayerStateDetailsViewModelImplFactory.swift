//
//  CurrentPlayerStateDetailsViewModelImplFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 30.09.2022.
//

import Foundation

public final class CurrentPlayerStateDetailsViewModelImplFactory: CurrentPlayerStateDetailsViewModelFactory {

    // MARK: - Properties

    private let playMediaUseCase: PlayMediaWithInfoUseCase
    private let subtitlesPresenterViewModelFactory: SubtitlesPresenterViewModelFactory

    // MARK: - Initializers

    public init(
        playMediaUseCase: PlayMediaWithInfoUseCase,
        subtitlesPresenterViewModelFactory: SubtitlesPresenterViewModelFactory
    ) {

        self.playMediaUseCase = playMediaUseCase
        self.subtitlesPresenterViewModelFactory = subtitlesPresenterViewModelFactory
    }

    // MARK: - Methods

    public func create(delegate: CurrentPlayerStateDetailsViewModelDelegate) -> CurrentPlayerStateDetailsViewModel {

        return CurrentPlayerStateDetailsViewModelImpl(
            delegate: delegate,
            playMediaUseCase: playMediaUseCase,
            subtitlesPresenterViewModelFactory: subtitlesPresenterViewModelFactory
        )
    }
}
