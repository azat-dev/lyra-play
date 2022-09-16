//
//  MainTabBarViewController+Layout.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 03.09.22.
//

import Foundation
import UIKit

extension MainTabBarViewController {
    
    final class Layout {
        
        static func apply() {
        }
        
        static func apply(
            contentView: UIView,
            tabBar: UITabBar,
            currentPlayerStateView: CurrentPlayerStateView
        ) {
            
            currentPlayerStateView.constraintToHorizontalEdges(of: contentView)
            currentPlayerStateView.setContentHuggingPriority(.defaultHigh, for: .vertical)
            currentPlayerStateView.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
            
            NSLayoutConstraint.activate([
                
                currentPlayerStateView.bottomAnchor.constraint(equalTo: tabBar.topAnchor)
            ])
        }
    }
}

