//
//  AudioFilesBrowserCell+Layout.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 28.06.22.
//

import Foundation
import UIKit

extension AudioFilesBrowserCell {

    final class Layout {
        
        static func apply(
            contentView: UIView,
            coverImageView: UIImageView,
            textGroup: UIStackView,
            titleLabel: UILabel,
            descriptionLabel: UILabel
        ) {
            
            let imageSize: CGFloat = 50
            
            coverImageView.translatesAutoresizingMaskIntoConstraints = false
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
            textGroup.translatesAutoresizingMaskIntoConstraints = false
            
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
        }
    }
}
