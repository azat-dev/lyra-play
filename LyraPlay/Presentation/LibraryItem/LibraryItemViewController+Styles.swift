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
        
        static var imageCornerRadius: CGFloat {
            0
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
            
            contentView.backgroundColor = .systemBackground
        }
        
        static func apply(imageView: ImageViewShadowed) {
         
            imageView.sizeToFit()
            

            imageView.shadowView.shape = Self.imageShape
            imageView.containerView.shape = Self.imageShape
            
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
            
            titleLabel.font = Fonts.RedHatDisplay.bold.preferred(with: .headline)
            titleLabel.textAlignment = .left
            titleLabel.textColor = UIColor(named: "Color.Text")
        }
        
        static func apply(artistLabel: UILabel) {
            
            artistLabel.font = Fonts.RedHatDisplay.medium.preferred(with: .footnote)
            artistLabel.textAlignment = .left
            artistLabel.textColor = UIColor(named: "Color.Text")
        }
        
        static func apply(durationLabel: UILabel) {
            
            durationLabel.font = Fonts.RedHatDisplay.medium.preferred(with: .footnote)
            durationLabel.textAlignment = .left
            durationLabel.textColor = UIColor(named: "Color.Text")
        }
        
        static func apply(playButton: UIButton) {
            
            playButton.setTitle("Play", for: .normal)
            playButton.setTitleColor(.black, for: .normal)
        }
        
        static func apply(pauseButton: UIButton) {
            
            pauseButton.setTitle("Pause", for: .normal)
            pauseButton.setTitleColor(.black, for: .normal)
        }
    }
}
