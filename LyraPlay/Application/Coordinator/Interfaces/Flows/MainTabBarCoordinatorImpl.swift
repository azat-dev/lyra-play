//
//  MainTabBarCoordinatorImpl.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 03.09.22.
//

import Foundation

public final class MainTabBarCoordinatorImpl: BaseCoordinator, MainTabBarCoordinator {

    // MARK: - Properties
    
    private let libraryCoordinatorFactory: LibraryCoordinatorFactory
    
    // MARK: - Initializers
    
    public init(libraryCoordinatorFactory: LibraryCoordinatorFactory) {
        
        self.libraryCoordinatorFactory = libraryCoordinatorFactory
    }
    
    // MARK: - Methods
    
    public func start(at tabBarContainer: TabBarPresentationContainer) {
    }
}

// MARK: - Input Methods

extension MainTabBarCoordinatorImpl {
    
    public func runLibraryFlow() {
        
//        let libraryCoordinator = libraryCoordinatorFactory.create()
//        libraryCoordinator.start(at: tabContainer)
    }
    
    public func runDictionaryFlow() {
        fatalError()
    }
}
