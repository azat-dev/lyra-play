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
    private let dictionaryCoordinatorFactory: DictionaryCoordinatorFactory
    
    public init(
        mainTabBarViewModelFactory: MainTabBarViewModelFactory,
        mainTabBarViewFactory: MainTabBarViewFactory,
        libraryCoordinatorFactory: LibraryCoordinatorFactory,
        dictionaryCoordinatorFactory: DictionaryCoordinatorFactory
    ) {
        
        self.mainTabBarViewModelFactory = mainTabBarViewModelFactory
        self.mainTabBarViewFactory = mainTabBarViewFactory
        self.libraryCoordinatorFactory = libraryCoordinatorFactory
        self.dictionaryCoordinatorFactory = dictionaryCoordinatorFactory
    }
    
    public func create() -> MainTabBarCoordinator {
        
        return MainTabBarCoordinatorImpl(
            mainTabBarViewModelFactory: mainTabBarViewModelFactory,
            mainTabBarViewFactory: mainTabBarViewFactory,
            libraryCoordinatorFactory: libraryCoordinatorFactory,
            dictionaryCoordinatorFactory: dictionaryCoordinatorFactory
        )
    }
}
