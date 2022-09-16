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

        static let fontTitle = Fonts.RedHatDisplay.bold.preferred(with: .subheadline)
        static let fontDescription = Fonts.RedHatDisplay.medium.preferred(with: .footnote)
        
        static let iconPlay = UIImage(systemName: "play")
        static let iconPause = UIImage(systemName: "pause")
        
        static func apply(contentView: UIView) {
            
            contentView.backgroundColor = .red
        }
        
        static func apply(titleLabel label: UILabel) {
            
            label.font = fontTitle
        }
        
        static func apply(descriptionLabel label: UILabel) {
            
            label.font = fontDescription
        }
        
        static func apply(imageView: UIImageView) {
            
            imageView.layer.cornerRadius = 3
        }
        
        static func apply(button: UIImageView) {
            
            button.tintColor = .white
        }
        
        static func apply(playButton button: UIImageView) {
        
            apply(button: button)
            button.image = iconPlay
        }
        
        static func apply(pauseButton button: UIImageView) {
        
            apply(button: button)
            button.image = iconPause
        }
    }
}
