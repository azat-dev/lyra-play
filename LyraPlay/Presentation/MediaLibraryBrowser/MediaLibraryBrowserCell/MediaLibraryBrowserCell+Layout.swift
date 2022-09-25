//
//  MediaLibraryBrowserCell+Layout.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 28.06.22.
//

import Foundation
import UIKit

extension MediaLibraryBrowserCell {

    final class Layout {
        
        // MARK: - Properties
        
        static let padding = UIEdgeInsets(top: 10, left: 25, bottom: 10, right: 25)
        static let seperatorHeight = 0.5
        static let playButtonSize = CGFloat(25)
        
        static let imageSize: CGFloat = 50
        
        // MARK: - Methods
        
        static func apply(
            contentView: UIView,
            coverImageView: UIImageView,
            textGroup: UIStackView,
            titleLabel: UILabel,
            descriptionLabel: UILabel,
            bottomBorder: UIView
        ) {
            
            coverImageView.translatesAutoresizingMaskIntoConstraints = false
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
            textGroup.translatesAutoresizingMaskIntoConstraints = false
            bottomBorder.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                
                coverImageView.heightAnchor.constraint(equalToConstant: imageSize),
                coverImageView.widthAnchor.constraint(equalToConstant: imageSize),
                
                coverImageView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 10),
                coverImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
                coverImageView.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor, constant: 10),
                coverImageView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -10),

                textGroup.centerYAnchor.constraint(equalTo: coverImageView.centerYAnchor),
                textGroup.leftAnchor.constraint(equalTo: coverImageView.rightAnchor, constant: 10),
                textGroup.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -10),
                textGroup.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor, constant: 10),
                textGroup.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -10),
            ])
            
            NSLayoutConstraint.activate([
                
                bottomBorder.leftAnchor.constraint(equalTo: textGroup.leftAnchor),
                bottomBorder.rightAnchor.constraint(equalTo: textGroup.rightAnchor),
                
                bottomBorder.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
                bottomBorder.heightAnchor.constraint(equalToConstant: seperatorHeight)
            ])
        }
    }
}
