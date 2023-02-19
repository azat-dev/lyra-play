//
//  CurrentPlayerStateDetailsViewControllerFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 30.09.2022.
//

import Foundation

public final class CurrentPlayerStateDetailsViewControllerFactory: CurrentPlayerStateDetailsViewFactory {

    // MARK: - Initializers

    public init() {}

    // MARK: - Methods

    public func make(viewModel: CurrentPlayerStateDetailsViewModel) -> CurrentPlayerStateDetailsViewController {

        return CurrentPlayerStateDetailsViewController(viewModel: viewModel)
    }
}
