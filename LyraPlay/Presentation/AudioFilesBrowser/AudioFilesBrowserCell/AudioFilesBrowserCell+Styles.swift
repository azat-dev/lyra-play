//
//  AudioFilesBrowserCell+Styles.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 28.06.22.
//

import Foundation
import UIKit

extension AudioFilesBrowserCell {

    final class Styles {
        
        static func apply(coverImageView: UIImageView) {
        
            coverImageView.layer.cornerRadius = 5
            coverImageView.clipsToBounds = true
        }

        static func apply(titleLabel: UILabel) {
            
            titleLabel.numberOfLines = 1
            titleLabel.font = .preferredFont(forTextStyle: .headline)
            titleLabel.textColor = UIColor(named: "AudioFilesBrowser.cell.titleColor")
            titleLabel.textAlignment = .left
        }
        
        static func apply(descriptionLabel: UILabel) {
            
            descriptionLabel.numberOfLines = 1
            descriptionLabel.font = .preferredFont(forTextStyle: .subheadline)
            descriptionLabel.textColor = UIColor(named: "AudioFilesBrowser.cell.descriptionColor")
            descriptionLabel.textAlignment = .left
        }
    }
}
