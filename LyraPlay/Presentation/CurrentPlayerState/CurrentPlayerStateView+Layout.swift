//
//  CurrentPlayerStateView+Layout.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 16.09.22.
//

import Foundation
import UIKit

extension CurrentPlayerStateView {
    
    final class Layout {
        
        static let imageSize: CGFloat = 50
        static let togglePlayButtonSize: CGFloat = 40
        static let contentViewPadding = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 5)
        
        static func apply(
            view contentView: UIView,
            blurView: UIVisualEffectView,
            imageView: UIImageView,
            textGroup: UIStackView,
            titleLabel: UILabel,
            descriptionLabel: UILabel,
            togglePlayButton: UIButton,
            separatorView: UIView
        ) {
            
            textGroup.axis = .vertical
            textGroup.alignment = .leading
            
            imageView.translatesAutoresizingMaskIntoConstraints = false
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
            textGroup.translatesAutoresizingMaskIntoConstraints = false
            
            togglePlayButton.translatesAutoresizingMaskIntoConstraints = false
            
            blurView.constraintTo(view: contentView)
            separatorView.constraintToHorizontalEdges(of: contentView)
            
            NSLayoutConstraint.activate([
                
                imageView.heightAnchor.constraint(equalToConstant: imageSize),
                imageView.widthAnchor.constraint(equalToConstant: imageSize),
                
                imageView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: contentViewPadding.left),
                imageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
                imageView.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor, constant: contentViewPadding.top),
                imageView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -contentViewPadding.bottom),
                
                textGroup.centerYAnchor.constraint(equalTo: imageView.centerYAnchor),
                textGroup.leftAnchor.constraint(equalTo: imageView.rightAnchor, constant: 10),
                textGroup.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor, constant: 10),
                textGroup.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -10),
                
                separatorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
                separatorView.heightAnchor.constraint(equalToConstant: 1)
            ])
            
            NSLayoutConstraint.activate([
                
                togglePlayButton.leftAnchor.constraint(equalTo: textGroup.rightAnchor),
                togglePlayButton.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -contentViewPadding.right),
                
                togglePlayButton.centerYAnchor.constraint(equalTo: imageView.centerYAnchor),
                togglePlayButton.heightAnchor.constraint(equalTo: togglePlayButton.widthAnchor),
                togglePlayButton.heightAnchor.constraint(equalToConstant: togglePlayButtonSize)
            ])
        }
    }
}

