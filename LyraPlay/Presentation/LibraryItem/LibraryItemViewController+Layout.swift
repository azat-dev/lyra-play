//
//  LibraryItemViewController+Layout.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 03.07.22.
//

import Foundation
import UIKit

extension LibraryItemViewController {
    
    final class Layout {
        
        static func apply(
            view: UIView,
            activityIndicator: UIActivityIndicatorView,
            mainGroup: UIStackView,
            imageView: UIImageView,
            titleLabel: UILabel,
            artistLabel: UILabel
            
        ) {
            
            mainGroup.translatesAutoresizingMaskIntoConstraints = false
            activityIndicator.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                
                mainGroup.topAnchor.constraint(equalTo: view.topAnchor),
                mainGroup.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                mainGroup.leftAnchor.constraint(equalTo: view.leftAnchor),
                mainGroup.rightAnchor.constraint(equalTo: view.rightAnchor),
            ])
                        
            NSLayoutConstraint.activate([
                
                activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
            ])
        }
    }
}

