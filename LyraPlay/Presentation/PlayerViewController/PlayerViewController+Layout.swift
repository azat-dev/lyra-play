//
//  PlayerViewControllerLayout.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 30.06.22.
//

import Foundation
import UIKit

extension PlayerViewController {
    
    final class Layout {
        
        static func apply(
            view: UIView,
            activityIndicator: UIActivityIndicatorView
        ) {
           
            view.translatesAutoresizingMaskIntoConstraints = false
            activityIndicator.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                
                activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            ])
        }
    }
}
