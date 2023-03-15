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
        static let colorButtonBackground = UIColor(named: "Color.Group.Background")
        
        static let fontButton = Fonts.RedHatDisplay.bold.preferred(with: .footnote)
        
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
        
        static func apply(playButton button: UIButton, title: String) {

            var config = UIButton.Configuration.filled()
            
            var attrTitle = AttributedString(title)
            attrTitle.font = fontButton
            
            config.attributedTitle = attrTitle
            config.baseBackgroundColor = colorButtonBackground
            config.cornerStyle = .capsule
            config.titleAlignment = .center
            config.contentInsets.top = 15
            config.contentInsets.bottom = 15
            config.baseForegroundColor = .white

            button.configuration = config
        }
        
        static func apply(playButton: UIButton) {

            apply(playButton: playButton, title: "PLAY")
        }
        
        static func apply(pauseButton button: UIButton) {
            
            apply(playButton: button, title: "PAUSE")
        }
        
        static func apply(attachSubtitlesButton button: UIButton) {
         
            var config = UIButton.Configuration.plain()
            
            var attrTitle = AttributedString("ATTACH SUBTITLES")
            attrTitle.font = fontButton
            
            config.attributedTitle = attrTitle
            config.cornerStyle = .capsule
            config.titleAlignment = .center
            config.contentInsets.top = 15
            config.contentInsets.bottom = 15
            config.baseForegroundColor = .white
            
            config.background.backgroundColor = .clear
            config.background.strokeWidth = 3
            
            config.background.strokeColor = colorButtonBackground
            config.image = UIImage(systemName: "captions.bubble.fill")
            config.imagePadding = 5

            button.configuration = config
        }
        
        static func apply(activityIndicatorAttachingSubtitles activityIndicator: UIActivityIndicatorView) {
            
            activityIndicator.hidesWhenStopped = true
        }
        
        static func apply(activityIndicatorPrepareToPlay activityIndicator: UIActivityIndicatorView) {
            
            activityIndicator.hidesWhenStopped = true
        }
    }
}
