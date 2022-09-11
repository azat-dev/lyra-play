//
//  DictionaryListBrowserCell+Styles.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 19.08.22.
//

import Foundation
import UIKit

extension DictionaryListBrowserCell {

    final class Styles {
        
        // MARK: - Properties
        
        private static let secondaryTextColor = UIColor(named: "Color.Text.Secondary")
        private static let separatorColor = UIColor(named: "Color.Separator")
        private static let textColor = UIColor(named: "Color.Text")
        
        private static let titleFont: UIFont = Fonts.RedHatDisplay.medium.preferred(with: .title3)
        private static let descriptionFont: UIFont = Fonts.RedHatDisplay.regular.preferred(with: .subheadline)
        
        private static let playButtonIcon = UIImage(systemName: "speaker.wave.2.fill")
        
        
        // MARK: - Methods
        
        static func apply(contentView: UIView) {
            
            contentView.backgroundColor = .clear
        }
        
        static func apply(titleLabel: UILabel) {
            
            titleLabel.numberOfLines = 1
            titleLabel.font = titleFont
            titleLabel.textColor = textColor
            titleLabel.textAlignment = .left
        }
        
        static func apply(descriptionLabel: UILabel) {
            
            descriptionLabel.numberOfLines = 1
            descriptionLabel.font = descriptionFont
            descriptionLabel.textColor = secondaryTextColor
            descriptionLabel.textAlignment = .left
        }
        
        static func apply(textGroup: UIStackView) {
            
        }
        
        static func apply(bottomBorder: UIView) {
            
            bottomBorder.backgroundColor = separatorColor
        }
        
        static func apply(playButton: UIImageView) {
            
            playButton.image = playButtonIcon
            playButton.contentMode = .scaleAspectFit
            playButton.tintColor = textColor
        }
    }
}

