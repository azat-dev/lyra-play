//
//  MainTabBarViewControllerFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 03.09.2022.
//

import Foundation

public final class MainTabBarViewControllerFactory: MainTabBarViewFactory {
    
    // MARK: - Initializers

    public init() {}

    // MARK: - Methods

    public func make(viewModel: MainTabBarViewModel) -> MainTabBarViewController {

        return MainTabBarViewController(viewModel: viewModel)
    }
}
