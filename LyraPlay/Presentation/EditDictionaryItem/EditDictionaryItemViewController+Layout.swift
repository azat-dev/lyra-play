//
//  EditDictionaryItemViewController+Layout.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 12.09.22.
//

import Foundation
import UIKit

extension EditDictionaryItemViewController {
    
    final class Layout {
        
        static func apply(
            view: UIView,
            activityIndicator: UIActivityIndicatorView
        ) {
            
            view.translatesAutoresizingMaskIntoConstraints = false
            activityIndicator.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                
                activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            ])
        }
    }
}

