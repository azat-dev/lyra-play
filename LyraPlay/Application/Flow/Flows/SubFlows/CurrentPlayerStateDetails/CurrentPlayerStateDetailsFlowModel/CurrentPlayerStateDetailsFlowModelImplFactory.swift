//
//  CurrentPlayerStateDetailsFlowModelImplFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 30.09.2022.
//

import Foundation

public final class CurrentPlayerStateDetailsFlowModelImplFactory: CurrentPlayerStateDetailsFlowModelFactory {

    // MARK: - Properties

    private let currentPlayerStateDetailsViewModelFactory: CurrentPlayerStateDetailsViewModelFactory

    // MARK: - Initializers

    public init(currentPlayerStateDetailsViewModelFactory: CurrentPlayerStateDetailsViewModelFactory) {

        self.currentPlayerStateDetailsViewModelFactory = currentPlayerStateDetailsViewModelFactory
    }

    // MARK: - Methods

    public func make(delegate: CurrentPlayerStateDetailsFlowModelDelegate) -> CurrentPlayerStateDetailsFlowModel {

        return CurrentPlayerStateDetailsFlowModelImpl(
            delegate: delegate,
            currentPlayerStateDetailsViewModelFactory: currentPlayerStateDetailsViewModelFactory
        )
    }
}
