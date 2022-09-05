//
//  MainCoordinatorImpl.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 05.09.22.
//

import Foundation

public final class MainCoordinatorImpl: BaseCoordinator, MainCoordinator {
    
    // MARK: - Properties
    
    private let mainTabBarCoordinatorFactory: MainTabBarCoordinatorFactory
    
    // MARK: - Initializers
    
    public init(mainTabBarCoordinatorFactory: MainTabBarCoordinatorFactory) {
        
        self.mainTabBarCoordinatorFactory = mainTabBarCoordinatorFactory
    }
    
    // MARK: - Methods
    
    public func start(at container: StackPresentationContainer) {
    
        let mainTabBarCoordinator = mainTabBarCoordinatorFactory.create()
        mainTabBarCoordinator.start(at: container)
    }
}
