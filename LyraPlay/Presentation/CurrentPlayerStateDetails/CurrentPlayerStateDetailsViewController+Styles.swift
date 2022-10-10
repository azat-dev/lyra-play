//
//  CurrentPlayerStateDetailsViewController+Styles.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 30.09.22.
//

import Foundation
import UIKit

extension CurrentPlayerStateDetailsViewController {
    
    final class Styles {

        // MARK: - Properties
        
        private static let colorBackground = UIColor(named: "Color.Background")
        private static let cornerRadius: CGFloat = 20
        
        static let imageConfig = UIImage.SymbolConfiguration(weight: .bold)
        
        static let iconPlay = UIImage(systemName: "play.fill")
        static let iconPause = UIImage(systemName: "pause.fill")
        
        static let iconGoForward = UIImage(systemName: "goforward.30")
        static let iconGoBackward = UIImage(systemName: "gobackward.30")
        
        static let fontTitle = Fonts.RedHatDisplay.semiBold.preferred(with: .headline)
        static let fontSubtitle = Fonts.RedHatDisplay.regular.preferred(with: .subheadline)
        
        static let colorTrackMinimum = UIColor(named: "Color.Slider.Track.Minimum")
        static let colorTrackMaximum = UIColor(named: "Color.Slider.Track.Maximum")
        
        // MARK: - Methods
        
        static func apply(contentView: UIView) {
            
            contentView.backgroundColor = colorBackground
        }
        
        static func apply(titleLabel label: UILabel) {
            
            label.textAlignment = .left
            label.font = fontTitle
        }
        
        static func apply(subtitleLabel label: UILabel) {
            
            label.textAlignment = .left
            label.font = fontSubtitle
        }
        
        static func apply(activityIndicator: UIActivityIndicatorView) {
            
            activityIndicator.hidesWhenStopped = true
        }
        
        static func apply(coverImage imageView: UIImageView) {
            
            imageView.layer.cornerRadius = cornerRadius
            imageView.contentMode = .scaleAspectFill
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
        
        static func apply(goForwardButton button: UIImageView) {
            
            apply(button: button)
            button.image = iconGoForward
        }
        
        static func apply(goBackwardButton button: UIImageView) {
            
            apply(button: button)
            button.image = iconGoForward
        }
        
        static func apply(slider: UISlider) {

            slider.minimumTrackTintColor = colorTrackMinimum
            slider.maximumTrackTintColor = colorTrackMaximum
        }
    }
}
