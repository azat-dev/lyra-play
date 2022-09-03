//
//  MainTabBarViewModelImplFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 03.09.2022.
//

import Foundation

public final class MainTabBarViewModelImplFactory: MainTabBarViewModelFactory {

    // MARK: - Initializers

    public init() {}

    // MARK: - Methods

    public func create(coordinator: MainTabBarCoordinator) -> some MainTabBarViewModel {

        return MainTabBarViewModelImpl(coordinator: coordinator)
    }
}
