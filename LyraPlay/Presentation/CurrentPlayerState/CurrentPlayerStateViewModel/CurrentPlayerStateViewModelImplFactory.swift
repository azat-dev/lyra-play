//
//  CurrentPlayerStateViewModelImplFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 15.09.2022.
//

import Foundation

public final class CurrentPlayerStateViewModelImplFactory: CurrentPlayerStateViewModelFactory {

    // MARK: - Properties

    private let playMediaUseCase: PlayMediaWithTranslationsUseCase
    private let showMediaInfoUseCase: ShowMediaInfoUseCase

    // MARK: - Initializers

    public init(
        playMediaUseCase: PlayMediaWithTranslationsUseCase,
        showMediaInfoUseCase: ShowMediaInfoUseCase
    ) {

        self.playMediaUseCase = playMediaUseCase
        self.showMediaInfoUseCase = showMediaInfoUseCase
    }

    // MARK: - Methods

    public func create(delegate: CurrentPlayerStateViewModelDelegate) -> CurrentPlayerStateViewModel {

        return CurrentPlayerStateViewModelImpl(
            delegate: delegate,
            playMediaUseCase: playMediaUseCase,
            showMediaInfoUseCase: showMediaInfoUseCase
        )
    }
}
