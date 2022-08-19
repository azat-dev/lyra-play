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
        
        private static let secondaryTextColor = UIColor(named: "Color.Text.Secondary")
        private static let textColor = UIColor(named: "Color.Text")
        private static let titleFont: UIFont = Fonts.RedHatDisplay.medium.preferred(with: .headline)
        private static let descriptionFont: UIFont = Fonts.RedHatDisplay.regular.preferred(with: .subheadline)
        
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
    }
}

