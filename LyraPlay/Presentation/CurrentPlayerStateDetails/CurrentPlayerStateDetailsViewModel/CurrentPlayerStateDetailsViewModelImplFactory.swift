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

    // MARK: - Initializers

    public init(playMediaUseCase: PlayMediaWithInfoUseCase) {

        self.playMediaUseCase = playMediaUseCase
    }

    // MARK: - Methods

    public func create(delegate: CurrentPlayerStateDetailsViewModelDelegate) -> CurrentPlayerStateDetailsViewModel {

        return CurrentPlayerStateDetailsViewModelImpl(
            delegate: delegate,
            playMediaUseCase: playMediaUseCase
        )
    }
}