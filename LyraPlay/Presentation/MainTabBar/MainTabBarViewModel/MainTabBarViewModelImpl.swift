//
//  MainTabBarViewModelImpl.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 03.09.2022.
//

import Foundation

public final class MainTabBarViewModelImpl: MainTabBarViewModel {

    // MARK: - Properties

    private weak var coordinator: MainTabBarCoordinator?

    // MARK: - Initializers

    public init(coordinator: MainTabBarCoordinator) {

        self.coordinator = coordinator
    }
}

// MARK: - Input Methods

extension MainTabBarViewModelImpl {

    public func selectLibraryTab() -> Void {

        coordinator?.runLibraryFlow()
    }

    public func selectDictionaryTab() -> Void {

        coordinator?.runDictionaryFlow()
    }
}

// MARK: - Output Methods

extension MainTabBarViewModelImpl {

}
