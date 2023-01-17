//
//  CurrentPlayerStateDetailsViewController+Layout.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 30.09.22.
//

import Foundation
import UIKit

extension CurrentPlayerStateDetailsViewController {
    
    final class Layout {
        
        // MARK: - Properties
        
        private static let buttonSize: CGFloat = 38

        private static let contentGroupPadding = UIEdgeInsets(
            top: 10,
            left: 10,
            bottom: 10,
            right: 10
        )

        private static let buttonsGroupPadding = UIEdgeInsets(
            top: 15,
            left: 15,
            bottom: 15,
            right: 15
        )
        
        // MARK: - Methods
        
        static func apply(
            contentView: UIView,
            activityIndicator: UIActivityIndicatorView
        ) {
            
            activityIndicator.constraintToCenter(of: contentView)
        }
        
        static func apply(
            contentView: UIView,
            coverImageView: UIImageView
        ) {
            
            coverImageView.translatesAutoresizingMaskIntoConstraints = false
            coverImageView.constraintTo(view: contentView)
        }
        
        static func apply(
            contentView: UIView,
            blurView: UIVisualEffectView
        ) {
            
            blurView.translatesAutoresizingMaskIntoConstraints = false
            blurView.constraintTo(view: contentView)
        }
        
        static func apply(
            contentView: UIView,
            subtitlesPresenterView: SubtitlesPresenterView
        ) {
            
            subtitlesPresenterView.translatesAutoresizingMaskIntoConstraints = false
            subtitlesPresenterView.constraintTo(view: contentView)
        }
    }
}
