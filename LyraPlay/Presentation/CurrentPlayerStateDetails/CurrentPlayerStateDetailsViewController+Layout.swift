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
        
        private static let buttonSize: CGFloat = 44
        
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
            backgroundImageView: UIImageView
        ) {
            
            backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
            backgroundImageView.constraintTo(view: contentView)
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
            infoGroup: UIView,
            controlsGroup: UIView,
            subtitlesPresenterView: SubtitlesPresenterView
        ) {
            
            subtitlesPresenterView.translatesAutoresizingMaskIntoConstraints = false
            subtitlesPresenterView.constraintToHorizontalEdges(of: contentView)
            
            NSLayoutConstraint.activate([
                subtitlesPresenterView.topAnchor.constraint(equalTo: infoGroup.bottomAnchor),
                subtitlesPresenterView.bottomAnchor.constraint(equalTo: controlsGroup.topAnchor)
            ])
        }
        
        static func apply(
            contentView: UIView,
            infoGroup: UIView
        ) {
            
            infoGroup.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                
                infoGroup.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 20),
                infoGroup.leftAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leftAnchor, constant: 20),
                infoGroup.rightAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.rightAnchor, constant: -20)
            ])
        }
        
        static func apply(
            infoGroup: UIView,
            coverImageView: ImageViewShadowed,
            titleLabel: UILabel,
            subtitleLabel: UILabel
        ) {
            
            coverImageView.translatesAutoresizingMaskIntoConstraints = false
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
            
            coverImageView.contentMode = .scaleAspectFill
            
            let titleGroup = UILayoutGuide()
            infoGroup.addLayoutGuide(titleGroup)
            
            NSLayoutConstraint.activate([
                
                coverImageView.leftAnchor.constraint(equalTo: infoGroup.leftAnchor, constant: 10),
                coverImageView.heightAnchor.constraint(equalTo: coverImageView.widthAnchor),
                coverImageView.centerYAnchor.constraint(equalTo: titleGroup.centerYAnchor),
                coverImageView.heightAnchor.constraint(equalToConstant: 60),
                
                coverImageView.topAnchor.constraint(equalTo: infoGroup.topAnchor, constant: 10),
                coverImageView.bottomAnchor.constraint(equalTo: infoGroup.bottomAnchor, constant: -10)
            ])
            
            NSLayoutConstraint.activate([
                
                titleGroup.leftAnchor.constraint(equalTo: coverImageView.rightAnchor, constant: 10),
                titleGroup.rightAnchor.constraint(equalTo: infoGroup.rightAnchor),
            ])
            
            NSLayoutConstraint.activate([
                
                titleLabel.topAnchor.constraint(equalTo: titleGroup.topAnchor),
                titleLabel.leftAnchor.constraint(equalTo: titleGroup.leftAnchor),
                titleLabel.rightAnchor.constraint(equalTo: titleGroup.rightAnchor),
            ])
            
            NSLayoutConstraint.activate([
                
                subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
                subtitleLabel.leftAnchor.constraint(equalTo: titleGroup.leftAnchor),
                subtitleLabel.rightAnchor.constraint(equalTo: titleGroup.rightAnchor),
                subtitleLabel.bottomAnchor.constraint(equalTo: titleGroup.bottomAnchor),
            ])
        }
        
        static func apply(
            controlsGroup: UIView,
            sliderView: UISlider,
            togglePlayButton: UIButton,
            goBackwardButton: UIButton,
            goForwardButton: UIButton
        ) {
            
            
            sliderView.translatesAutoresizingMaskIntoConstraints = false
            togglePlayButton.translatesAutoresizingMaskIntoConstraints = false
            goBackwardButton.translatesAutoresizingMaskIntoConstraints = false
            goForwardButton.translatesAutoresizingMaskIntoConstraints = false
            
            let buttonsGroup = UILayoutGuide()
            controlsGroup.addLayoutGuide(buttonsGroup)
            
            NSLayoutConstraint.activate([
                sliderView.leftAnchor.constraint(equalTo: controlsGroup.leftAnchor),
                sliderView.rightAnchor.constraint(equalTo: controlsGroup.rightAnchor),
                sliderView.topAnchor.constraint(equalTo: controlsGroup.topAnchor),
                
                buttonsGroup.topAnchor.constraint(equalTo: sliderView.bottomAnchor, constant: 10),
                buttonsGroup.leftAnchor.constraint(equalTo: controlsGroup.leftAnchor),
                buttonsGroup.rightAnchor.constraint(equalTo: controlsGroup.rightAnchor),
                buttonsGroup.bottomAnchor.constraint(equalTo: controlsGroup.bottomAnchor),
            ])
            
            NSLayoutConstraint.activate([
                
                togglePlayButton.centerXAnchor.constraint(equalTo: buttonsGroup.centerXAnchor),
                togglePlayButton.topAnchor.constraint(equalTo: buttonsGroup.topAnchor),
                togglePlayButton.bottomAnchor.constraint(equalTo: buttonsGroup.bottomAnchor),
                togglePlayButton.heightAnchor.constraint(equalTo: togglePlayButton.widthAnchor),
                togglePlayButton.heightAnchor.constraint(equalToConstant: Self.buttonSize),
                
                goBackwardButton.rightAnchor.constraint(equalTo: togglePlayButton.leftAnchor, constant: -40),
                goBackwardButton.heightAnchor.constraint(equalTo: goBackwardButton.widthAnchor),
                goBackwardButton.heightAnchor.constraint(equalToConstant: Self.buttonSize),
                goBackwardButton.centerYAnchor.constraint(equalTo: togglePlayButton.centerYAnchor),
                
                goForwardButton.leftAnchor.constraint(equalTo: togglePlayButton.rightAnchor, constant: 40),
                goForwardButton.heightAnchor.constraint(equalTo: goForwardButton.widthAnchor),
                goForwardButton.heightAnchor.constraint(equalToConstant: Self.buttonSize),
                goForwardButton.centerYAnchor.constraint(equalTo: togglePlayButton.centerYAnchor),
            ])
        }
        
        static func apply(
            contentView: UIView,
            controlsGroup: UIView
        ) {
            
            controlsGroup.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                controlsGroup.leftAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leftAnchor, constant: 10),
                controlsGroup.rightAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.rightAnchor, constant: -10),
                controlsGroup.bottomAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            ])
        }
    }
    
}
