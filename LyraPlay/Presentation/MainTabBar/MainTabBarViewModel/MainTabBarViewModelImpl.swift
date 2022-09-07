//
//  MainTabBarViewModelImpl.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 03.09.2022.
//

import Foundation

public final class MainTabBarViewModelImpl: MainTabBarViewModel {

    // MARK: - Properties

    private var delegate: MainTabBarViewModelDelegate

    // MARK: - Initializers

    public init(delegate: MainTabBarViewModelDelegate) {

        self.delegate = delegate
    }
}

// MARK: - Input Methods

extension MainTabBarViewModelImpl {

    public func selectLibraryTab() -> Void {

        delegate.runLibraryFlow()
    }

    public func selectDictionaryTab() -> Void {

        delegate.runDictionaryFlow()
    }
}

// MARK: - Output Methods

extension MainTabBarViewModelImpl {

}
