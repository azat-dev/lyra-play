//
//  CurrentPlayerStateDetailsViewController+Layout.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 30.09.22.
//

import Foundation
import UIKit

extension CurrentPlayerStateDetailsViewController {
    
    final class Layout {
        
        // MARK: - Properties
        
        private static let buttonSize: CGFloat = 40
        
        // MARK: - Methods
        
        static func apply(
            buttonsGroup: UIView,
            togglePlayButton: UIImageView
        ) {
            
            togglePlayButton.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([

                togglePlayButton.topAnchor.constraint(equalTo: buttonsGroup.topAnchor, constant: 10),
                togglePlayButton.bottomAnchor.constraint(equalTo: buttonsGroup.bottomAnchor, constant: -10),
                
                togglePlayButton.heightAnchor.constraint(equalTo: togglePlayButton.widthAnchor),
                togglePlayButton.widthAnchor.constraint(equalToConstant: buttonSize),
                
                togglePlayButton.centerXAnchor.constraint(equalTo: buttonsGroup.centerXAnchor)
            ])
        }
        
        static func apply(
            contentGroup: UIStackView,
            coverImageView: UIImageView,
            titleLabel: UILabel,
            subtitleLabel: UILabel
        ) {
            
            NSLayoutConstraint.activate([
                
                coverImageView.heightAnchor.constraint(equalTo: coverImageView.widthAnchor),
                coverImageView.widthAnchor.constraint(equalTo: contentGroup.widthAnchor, multiplier: 0.8)
            ])
        }
        
        static func apply(
            view: UIView,
            activityIndicator: UIActivityIndicatorView,
            contentGroup: UIStackView
        ) {
            
            activityIndicator.constraintToCenter(of: view)
            contentGroup.axis = .vertical

            contentGroup.constraintTo(view: view)
        }
    }
}

