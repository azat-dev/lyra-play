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
            imageView.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                
                mainGroup.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                mainGroup.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
                mainGroup.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
                mainGroup.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            ])

            NSLayoutConstraint.activate([
                
                imageView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.85),
                imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor),
                
                imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                imageView.topAnchor.constraint(equalTo: mainGroup.topAnchor, constant: 0)
            ])
            
            titleLabel .constraintToHorizontalEdges(of: imageView)
            artistLabel.constraintToHorizontalEdges(of: imageView)
            durationLabel.constraintToHorizontalEdges(of: imageView)
            playButton.constraintToHorizontalEdges(of: imageView)
            attachSubtitlesButton.constraintToHorizontalEdges(of: imageView)
            
            titleLabel.constraintToHorizontalEdges(of: imageView)
            
            NSLayoutConstraint.activate([
                
                titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 10),
                artistLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 0),
                durationLabel.topAnchor.constraint(equalTo: artistLabel.bottomAnchor, constant: 0),
                playButton.topAnchor.constraint(equalTo: durationLabel.bottomAnchor, constant: 0),
                attachSubtitlesButton.topAnchor.constraint(equalTo: playButton.bottomAnchor, constant: 15),
            ])
            
            activityIndicator.constraintToCenter(of: view)
        }
        
        static func apply(
            button: UIButton,
            activityIndicator: UIActivityIndicatorView
        ) {
            activityIndicator.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
            
                activityIndicator.rightAnchor.constraint(equalTo: button.titleLabel!.leftAnchor, constant: -10),
                activityIndicator.centerYAnchor.constraint(equalTo: button.titleLabel!.centerYAnchor)
            ])
        }
    }
}

