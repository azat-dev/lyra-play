//
//  LibraryItemViewController+Styles.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 03.07.22.
//

import Foundation
import UIKit

extension LibraryItemViewController {
    
    final class Styles {
        
        static let textColor = UIColor(named: "Color.Text")
        static let textColorSecondary = UIColor(named: "Color.Text.Secondary")
        
        static var imageCornerRadius: CGFloat {
            10
        }
        
        static var imageShape: ShapeCallback {
            get {
                let callback: ShapeCallback = { view in
                    return CGPath(
                        roundedRect: view.bounds,
                        cornerWidth: self.imageCornerRadius,
                        cornerHeight: self.imageCornerRadius,
                        transform: nil
                    )
                }
                
                return callback
            }
        }
        
        static func apply(contentView: UIView) {
            
            contentView.backgroundColor = UIColor(named: "Color.Background")
        }
        
        static func apply(imageView: ImageViewShadowed) {
         
            imageView.sizeToFit()
            
            imageView.shadowView.shape = Self.imageShape
            imageView.containerView.shape = Self.imageShape
            imageView.imageView.backgroundColor = .white
            
            let shadowColor = UIColor(red: 0.094, green: 0.153, blue: 0.3, alpha: 1).cgColor
            imageView.shadowView.shadows = [
                ShadowView.ShadowParams(
                    color: shadowColor,
                    opacity: 0.25,
                    radius: 15,
                    offset: CGSize(width: 0, height: 8)
                ),
            ]
            
        }
        
        static func apply(titleLabel: UILabel) {
            
            titleLabel.font = Fonts.RedHatDisplay.bold.preferred(with: .title3)
            titleLabel.textAlignment = .left
            titleLabel.textColor = textColor
        }
        
        static func apply(artistLabel: UILabel) {
            
            artistLabel.font = Fonts.RedHatDisplay.regular.preferred(with: .subheadline)
            artistLabel.textAlignment = .left
            artistLabel.textColor = textColorSecondary
        }
        
        static func apply(durationLabel: UILabel) {
            
            durationLabel.font = Fonts.RedHatDisplay.medium.preferred(with: .footnote)
            durationLabel.textAlignment = .left
            durationLabel.textColor = textColorSecondary
            durationLabel.isHidden = true
        }
        
        static func apply(playButton: UIButton) {
            
            playButton.setTitle("Play", for: .normal)
            playButton.setTitleColor(textColor, for: .normal)
        }
        
        static func apply(pauseButton: UIButton) {
            
            pauseButton.setTitle("Pause", for: .normal)
            pauseButton.setTitleColor(textColor, for: .normal)
        }
        
        
        static func apply(attachSubtitlesButton: UIButton) {
            
            attachSubtitlesButton.setTitle("Add subtitles", for: .normal)
            attachSubtitlesButton.setTitleColor(textColor, for: .normal)
        }
    }
}
