//
//  MainTabBarCoordinatorFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 05.09.22.
//

import Foundation

public protocol MainTabBarCoordinatorFactory {
    
    func create() -> MainTabBarCoordinator
}
