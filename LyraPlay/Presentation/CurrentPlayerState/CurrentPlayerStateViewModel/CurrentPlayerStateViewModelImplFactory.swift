//
//  CurrentPlayerStateViewModelImplFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 15.09.2022.
//

import Foundation

public final class CurrentPlayerStateViewModelImplFactory: CurrentPlayerStateViewModelFactory {

    // MARK: - Properties

    private let playMediaUseCase: PlayMediaWithInfoUseCase

    // MARK: - Initializers

    public init(playMediaUseCase: PlayMediaWithInfoUseCase) {

        self.playMediaUseCase = playMediaUseCase
    }

    // MARK: - Methods

    public func create(delegate: CurrentPlayerStateViewModelDelegate) -> CurrentPlayerStateViewModel {

        return CurrentPlayerStateViewModelImpl(
            delegate: delegate,
            playMediaUseCase: playMediaUseCase
        )
    }
}
