//
//  MainTabBarViewController+Styles.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 03.09.22.
//

import Foundation
import UIKit

extension MainTabBarViewController {
    
    final class Styles {
        
        // MARK: - Properties
        
        private static let iconColor = UIColor(named: "Color.Text.Secondary")
        private static let activeIconColor = UIColor(named: "Color.Text")
        
        // MARK: - Methods
        
        static func apply(tabBar: UITabBar) {
            
            tabBar.barStyle = .default
            tabBar.backgroundImage = UIImage()
            tabBar.shadowImage = UIImage()
            tabBar.backgroundColor = .clear
            tabBar.tintColor = activeIconColor
            tabBar.barTintColor = .clear
            tabBar.unselectedItemTintColor = iconColor
        }
        
        static func apply(tabBarBackground: UIVisualEffectView) {
            
            tabBarBackground.effect = UIBlurEffect(style: .systemUltraThinMaterialDark)
        }
    }
}
