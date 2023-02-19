//
//  CurrentPlayerStateDetailsFlowPresenterImplFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 30.09.2022.
//

import Foundation

public final class CurrentPlayerStateDetailsFlowPresenterImplFactory: CurrentPlayerStateDetailsFlowPresenterFactory {

    // MARK: - Properties

    private let currentPlayerStateDetailsViewControllerFactory: CurrentPlayerStateDetailsViewControllerFactory

    // MARK: - Initializers

    public init(currentPlayerStateDetailsViewControllerFactory: CurrentPlayerStateDetailsViewControllerFactory) {

        self.currentPlayerStateDetailsViewControllerFactory = currentPlayerStateDetailsViewControllerFactory
    }

    // MARK: - Methods

    public func make(for flowModel: CurrentPlayerStateDetailsFlowModel) -> CurrentPlayerStateDetailsFlowPresenter {

        return CurrentPlayerStateDetailsFlowPresenterImpl(
            flowModel: flowModel,
            currentPlayerStateDetailsViewControllerFactory: currentPlayerStateDetailsViewControllerFactory
        )
    }
}
