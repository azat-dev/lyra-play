//
//  AppCoordinator.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 12.06.22.
//

import Foundation
import UIKit

// MARK: - Interfaces

protocol AppCoordinator {
    
    func start()
}

// MARK: - Implementations

final class DefaultAppCoordinator: AppCoordinator {
    
    private let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        
        self.navigationController = navigationController
    }
    
    func start() {
        
        let vc = ViewController()
        navigationController.pushViewController(vc, animated: false)
    }
}
