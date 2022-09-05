//
//  MainTabBarCoordinatorImplFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 05.09.22.
//

import Foundation

public final class MainTabBarCoordinatorImplFactory: MainTabBarCoordinatorFactory {
    
    private let mainTabBarViewModelFactory: MainTabBarViewModelFactory
    private let mainTabBarViewFactory: MainTabBarViewFactory
    private let libraryCoordinatorFactory: LibraryCoordinatorFactory
    
    public init(
        mainTabBarViewModelFactory: MainTabBarViewModelFactory,
        mainTabBarViewFactory: MainTabBarViewFactory,
        libraryCoordinatorFactory: LibraryCoordinatorFactory
    ) {
        
        self.mainTabBarViewModelFactory = mainTabBarViewModelFactory
        self.mainTabBarViewFactory = mainTabBarViewFactory
        self.libraryCoordinatorFactory = libraryCoordinatorFactory
    }
    
    public func create() -> MainTabBarCoordinator {
        
        return MainTabBarCoordinatorImpl(
            mainTabBarViewModelFactory: mainTabBarViewModelFactory,
            mainTabBarViewFactory: mainTabBarViewFactory,
            libraryCoordinatorFactory: libraryCoordinatorFactory
        )
    }
}
