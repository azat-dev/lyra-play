//
//  MainTabBarCoordinator.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 03.09.22.
//

import Foundation

public protocol MainTabBarCoordinatorInput {
    
    func runLibraryFlow()
    
    func runDictionaryFlow()
}

public protocol MainTabBarCoordinator: BaseCoordinator, MainTabBarCoordinatorInput {
    
    func start(at: StackPresentationContainer)
}
