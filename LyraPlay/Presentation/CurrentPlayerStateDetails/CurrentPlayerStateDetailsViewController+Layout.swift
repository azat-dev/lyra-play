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
            subtitlesPresenterView: SubtitlesPresenterView
        ) {
            
            subtitlesPresenterView.translatesAutoresizingMaskIntoConstraints = false
            subtitlesPresenterView.constraintToHorizontalEdges(of: contentView)
            
            NSLayoutConstraint.activate([
                subtitlesPresenterView.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor),
                subtitlesPresenterView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
            ])
        }
        
        static func apply(
            contentView: UIView,
            infoGroup: UIView
        ) {
            
            infoGroup.constraintToHorizontalEdges(of: contentView)
            
            NSLayoutConstraint.activate([
                infoGroup.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor)
            ])
        }
        
        static func apply(
            infoGroup: UIView,
            coverImageView: UIImageView,
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
                coverImageView.heightAnchor.constraint(equalToConstant: 60)
            ])
            
            NSLayoutConstraint.activate([
                
                titleGroup.topAnchor.constraint(equalTo: infoGroup.topAnchor),
                titleGroup.bottomAnchor.constraint(equalTo: infoGroup.bottomAnchor),
                titleGroup.leftAnchor.constraint(equalTo: coverImageView.rightAnchor, constant: 10),
                titleGroup.rightAnchor.constraint(equalTo: infoGroup.rightAnchor, constant: 10),
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
    }
}
