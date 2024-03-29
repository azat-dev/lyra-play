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
        private static let imageCornerRadius: CGFloat = 5
        
        static let imageConfig = UIImage.SymbolConfiguration(weight: .bold)
        
        static let iconPlay = UIImage(systemName: "play.fill")
        static let iconPause = UIImage(systemName: "pause.fill")
        
        static let iconGoForward = UIImage(systemName: "goforward.15", withConfiguration: UIImage.SymbolConfiguration(weight: .light))
        static let iconGoBackward = UIImage(systemName: "gobackward.15", withConfiguration: UIImage.SymbolConfiguration(weight: .light))
        
        static let fontTitle = Fonts.RedHatDisplay.bold.preferred(with: .headline)
        static let fontSubtitle = Fonts.RedHatDisplay.semiBold.preferred(with: .subheadline)
        
        static let colorTrackMinimum = UIColor(named: "Color.Slider.Track.Minimum")
        static let colorTrackMaximum = UIColor(named: "Color.Slider.Track.Maximum")
        
        static let shadowColor = UIColor(red: 0.094, green: 0.153, blue: 0.3, alpha: 1)
        
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
            label.layer.opacity = 0.5
            label.font = fontSubtitle
        }
        
        static func apply(activityIndicator: UIActivityIndicatorView) {
            
            activityIndicator.hidesWhenStopped = true
        }
        
        static func apply(backgroundImage imageView: UIImageView) {
            
            imageView.contentMode = .scaleAspectFill
        }
        
        static func apply(blurView: UIVisualEffectView) {
            
            blurView.effect = UIBlurEffect(style: .systemThinMaterialDark)
        }
        
        static func apply(coverImageView shadowedImageView: ImageViewShadowed) {
            
            shadowedImageView.shadowView.shadows = [
                ShadowView.ShadowParams(
                    color: Self.shadowColor.cgColor,
                    opacity: 0.55,
                    radius: 10,
                    offset: CGSize(width: 0, height: 8)
                ),
            ]
            
            shadowedImageView.containerView.shape = Self.imageShape
            shadowedImageView.shadowView.shape = Self.imageShape
        }
        
        static func apply(backgroundImageView imageView: UIImageView) {
            
            imageView.layer.cornerRadius = imageCornerRadius
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
        }
        
        static func apply(button: UIButton) {
            
            button.tintColor = .white
            button.contentVerticalAlignment = .fill
            button.contentHorizontalAlignment = .fill
            button.imageView?.contentMode = .scaleAspectFit
            button.imageEdgeInsets = .init(top: 5, left: 5, bottom: 5, right: 5)
            
            button.imageView?.contentMode = .scaleAspectFit
            button.setTitle(nil, for: .normal)
        }
        
        static func apply(playButton button: UIButton) {
            
            apply(button: button)
            button.setImage(iconPlay, for: .normal)
        }
        
        static func apply(pauseButton button: UIButton) {
            
            apply(button: button)
            button.setImage(iconPause, for: .normal)
        }
        
        static func apply(goForwardButton button: UIButton) {
            
            apply(button: button)
            button.setImage(iconGoForward, for: .normal)
        }
        
        static func apply(goBackwardButton button: UIButton) {
            
            apply(button: button)
            button.setImage(iconGoBackward, for: .normal)
        }
        
        static func apply(slider: UISlider) {
            
            slider.minimumTrackTintColor = colorTrackMinimum
            slider.maximumTrackTintColor = colorTrackMaximum
            slider.thumbTintColor = .white
            slider.minimumTrackTintColor = .white
            slider.maximumTrackTintColor = .gray
        }
    }
}
