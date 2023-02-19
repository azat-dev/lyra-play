//
//  MainTabBarViewModelImplFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 03.09.2022.
//

import Foundation

public final class MainTabBarViewModelImplFactory: MainTabBarViewModelFactory {

    // MARK: - Properties
    
    private let currentPlayerStateViewModelFactory: CurrentPlayerStateViewModelFactory
    
    // MARK: - Initializers

    public init(
        currentPlayerStateViewModelFactory: CurrentPlayerStateViewModelFactory
    ) {
        
        self.currentPlayerStateViewModelFactory = currentPlayerStateViewModelFactory
    }

    // MARK: - Methods

    public func make(delegate: MainTabBarViewModelDelegate) -> MainTabBarViewModel {

        return MainTabBarViewModelImpl(
            delegate: delegate,
            currentPlayerStateViewModelFactory: currentPlayerStateViewModelFactory
        )
    }
}
