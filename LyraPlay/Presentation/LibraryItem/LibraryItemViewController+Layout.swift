//
//  LibraryItemViewController+Layout.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 03.07.22.
//

import Foundation
import UIKit

extension LibraryItemViewController {
    
    final class Layout {
        
        static func apply(
            view: UIView,
            activityIndicator: UIActivityIndicatorView,
            mainGroup: UIView,
            imageView: ImageViewShadowed,
            titleLabel: UILabel,
            artistLabel: UILabel,
            durationLabel: UILabel,
            playButton: UIButton,
            attachSubtitlesButton: UIButton
        ) {
            
            mainGroup.translatesAutoresizingMaskIntoConstraints = false
            activityIndicator.translatesAutoresizingMaskIntoConstraints = false
            imageView.translatesAutoresizingMaskIntoConstraints = false
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            artistLabel.translatesAutoresizingMaskIntoConstraints = false
            durationLabel.translatesAutoresizingMaskIntoConstraints = false
            playButton.translatesAutoresizingMaskIntoConstraints = false
            attachSubtitlesButton.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                
                mainGroup.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                mainGroup.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
                mainGroup.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
                mainGroup.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            ])

            NSLayoutConstraint.activate([
                
                imageView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.87),
                imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor),
                
                imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                imageView.topAnchor.constraint(equalTo: mainGroup.topAnchor, constant: 20)
            ])
            
            NSLayoutConstraint.activate([
                
                titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 30),
                titleLabel.widthAnchor.constraint(lessThanOrEqualTo: imageView.widthAnchor, multiplier: 0.9),
                titleLabel.leftAnchor.constraint(equalTo: imageView.leftAnchor),
                titleLabel.rightAnchor.constraint(equalTo: imageView.rightAnchor),
            ])
            
            NSLayoutConstraint.activate([
                
                artistLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 0),
                artistLabel.leftAnchor.constraint(equalTo: imageView.leftAnchor),
                artistLabel.rightAnchor.constraint(equalTo: imageView.rightAnchor),
            ])
            
            NSLayoutConstraint.activate([
                
                durationLabel.topAnchor.constraint(equalTo: artistLabel.bottomAnchor, constant: 0),
                durationLabel.leftAnchor.constraint(equalTo: imageView.leftAnchor),
                durationLabel.rightAnchor.constraint(equalTo: imageView.rightAnchor),
            ])
            
            
            NSLayoutConstraint.activate([
                
                playButton.topAnchor.constraint(equalTo: durationLabel.bottomAnchor, constant: 0),
                playButton.leftAnchor.constraint(equalTo: imageView.leftAnchor),
                playButton.rightAnchor.constraint(equalTo: imageView.rightAnchor),
            ])
            
            NSLayoutConstraint.activate([
                
                attachSubtitlesButton.topAnchor.constraint(equalTo: playButton.bottomAnchor, constant: 20),
                attachSubtitlesButton.leftAnchor.constraint(equalTo: imageView.leftAnchor),
                attachSubtitlesButton.rightAnchor.constraint(equalTo: imageView.rightAnchor),
            ])
            
            NSLayoutConstraint.activate([

                activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
            ])
        }
    }
}

