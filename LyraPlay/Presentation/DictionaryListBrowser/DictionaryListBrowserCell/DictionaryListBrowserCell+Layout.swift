//
//  DictionaryListBrowserCell+Layout.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 19.08.22.
//

import Foundation
import UIKit

extension DictionaryListBrowserCell {

    final class Layout {

        static let padding = UIEdgeInsets(top: 10, left: 25, bottom: 10, right: 25)
        static let seperatorHeight = 0.5
        static let playButtonSize = CGFloat(25)
        
        static func apply(
            contentView: UIView,
            textGroup: UIStackView,
            titleLabel: UILabel,
            descriptionLabel: UILabel,
            bottomBorder: UIView,
            playButton: UIImageView
        ) {
            
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
            textGroup.translatesAutoresizingMaskIntoConstraints = false
            bottomBorder.translatesAutoresizingMaskIntoConstraints = false
            playButton.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
            
                textGroup.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: padding.left),
                textGroup.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -padding.right),
                textGroup.topAnchor.constraint(equalTo: contentView.topAnchor, constant: padding.top),
                textGroup.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding.bottom)
            ])
            
            NSLayoutConstraint.activate([
                
                bottomBorder.leftAnchor.constraint(equalTo: textGroup.leftAnchor),
                bottomBorder.rightAnchor.constraint(equalTo: textGroup.rightAnchor),
                bottomBorder.heightAnchor.constraint(equalToConstant: seperatorHeight)
            ])
            
            NSLayoutConstraint.activate([
              
                playButton.heightAnchor.constraint(equalToConstant: playButtonSize),
                playButton.widthAnchor.constraint(equalToConstant: playButtonSize),
                
                playButton.centerYAnchor.constraint(equalTo: textGroup.centerYAnchor),
                playButton.rightAnchor.constraint(equalTo: textGroup.rightAnchor)
            ])
        }
    }
}
