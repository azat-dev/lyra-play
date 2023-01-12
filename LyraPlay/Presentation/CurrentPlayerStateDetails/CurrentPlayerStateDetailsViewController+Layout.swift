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
        
        static func applyButtonSize(button: UIImageView) {
            
            button.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                
                button.heightAnchor.constraint(equalTo: button.widthAnchor),
                button.widthAnchor.constraint(equalToConstant: buttonSize)
            ])
        }
        
        static func apply(
            buttonsGroup: UIView,
            togglePlayButton: UIImageView,
            goForwardButton: UIImageView,
            goBackwardButton: UIImageView
        ) {
            
            applyButtonSize(button: togglePlayButton)
            applyButtonSize(button: goForwardButton)
            applyButtonSize(button: goBackwardButton)
            
            NSLayoutConstraint.activate([
                
                togglePlayButton.topAnchor.constraint(equalTo: buttonsGroup.topAnchor, constant: buttonsGroupPadding.top),
                togglePlayButton.bottomAnchor.constraint(equalTo: buttonsGroup.bottomAnchor, constant: -buttonsGroupPadding.bottom),
                
                togglePlayButton.centerXAnchor.constraint(equalTo: buttonsGroup.centerXAnchor),
            ])
            
            NSLayoutConstraint.activate([

                goBackwardButton.rightAnchor.constraint(equalTo: togglePlayButton.leftAnchor, constant: -50),
                goForwardButton.leftAnchor.constraint(equalTo: togglePlayButton.rightAnchor, constant: 50),

                goBackwardButton.centerYAnchor.constraint(equalTo: togglePlayButton.centerYAnchor),
                goForwardButton.centerYAnchor.constraint(equalTo: togglePlayButton.centerYAnchor),
            ])
        }
        
        static func apply(
            contentGroup: UIView,
            coverImageView: UIImageView,
            titleLabel: UILabel,
            subtitleLabel: UILabel,
            slider: UISlider,
            buttonsGroup: UIView
        ) {
            
            coverImageView.translatesAutoresizingMaskIntoConstraints = false
            slider.translatesAutoresizingMaskIntoConstraints = false
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            subtitleLabel.translatesAutoresizingMaskIntoConstraints = false

            slider.constraintToBottom(of: coverImageView, spacing: 10)

            titleLabel.constraintToBottom(of: slider, spacing: 10)
            subtitleLabel.constraintToBottom(of: titleLabel, spacing: 0)

            titleLabel.constraintToHorizontalEdges(of: contentGroup)
            subtitleLabel.constraintToHorizontalEdges(of: contentGroup)
            
            buttonsGroup.constraintToBottom(of: subtitleLabel, spacing: 10)
            buttonsGroup.constraintToHorizontalEdges(of: contentGroup)

            NSLayoutConstraint.activate([

                coverImageView.topAnchor.constraint(equalTo: contentGroup.topAnchor, constant: 10),
                coverImageView.centerXAnchor.constraint(equalTo: contentGroup.centerXAnchor),

                coverImageView.heightAnchor.constraint(equalTo: coverImageView.widthAnchor),
                coverImageView.widthAnchor.constraint(equalTo: contentGroup.widthAnchor, multiplier: 0.8),

                slider.widthAnchor.constraint(equalTo: contentGroup.widthAnchor),
            ])
        }
        
        static func apply(
            view: UIView,
            activityIndicator: UIActivityIndicatorView,
            contentGroup: UIView
        ) {
            
            activityIndicator.constraintToCenter(of: view)
            contentGroup.constraintTo(view: view, margins: contentGroupPadding)
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
