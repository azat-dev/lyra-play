//
//  CurrentPlayerStateView+Styles.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 16.09.22.
//

import Foundation
import UIKit

extension CurrentPlayerStateView {
    
    final class Styles {
        
        // MARK: - Properties
        
        static let fontTitle = Fonts.RedHatDisplay.bold.preferred(with: .subheadline)
        static let fontDescription = Fonts.RedHatDisplay.medium.preferred(with: .footnote)
        
        static let imageConfig = UIImage.SymbolConfiguration(weight: .bold)
        static let iconPlay = UIImage(systemName: "play.fill")
        static let iconPause = UIImage(systemName: "pause.fill")
        
        static let colorSeparator = UIColor(named: "Color.Separator")
        
        
        static let imageCornerRadius: CGFloat = 5
        
        // MARK: - Methods
        
        static func apply(contentView: UIView) {
        }
        
        static func apply(blurView: UIVisualEffectView) {
            
            blurView.effect = UIBlurEffect(style: .systemUltraThinMaterialDark)
        }
        
        static func apply(titleLabel label: UILabel) {
            
            label.font = fontTitle
        }
        
        static func apply(descriptionLabel label: UILabel) {
            
            label.font = fontDescription
        }
        
        static func apply(imageView: UIImageView) {
            
            imageView.layer.cornerRadius = imageCornerRadius
            imageView.clipsToBounds = true
        }
        
        static func apply(button: UIImageView) {
            
            button.tintColor = .white
            button.contentMode = .scaleAspectFit
        }
        
        static func apply(playButton button: UIImageView) {
            
            apply(button: button)
            button.image = iconPlay
        }
        
        static func apply(pauseButton button: UIImageView) {
            
            apply(button: button)
            button.image = iconPause
        }
        
        static func apply(separator: UIView) {
            
            separator.backgroundColor = colorSeparator
        }
    }
}
