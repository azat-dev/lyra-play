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
        
        private static let iconColor = UIColor(named: "Color.Text.Secondary")
        private static let activeIconColor = UIColor(named: "Color.Text")
 
        static func apply(tabBar: UITabBar) {
            
            tabBar.tintColor = activeIconColor
            tabBar.unselectedItemTintColor = iconColor
        }
    }
}
