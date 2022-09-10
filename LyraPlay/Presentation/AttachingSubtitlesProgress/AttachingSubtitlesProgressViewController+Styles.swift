//
//  AttachingSubtitlesProgressViewController+Styles.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 10.09.22.
//

import Foundation
import UIKit

extension AttachingSubtitlesProgressViewController {
    
    final class Styles {
        
        static func apply(contentView: UIView) {
            
            contentView.backgroundColor = .clear
        }
        
        static func apply(dialogBox: UIView) {
            
            dialogBox.backgroundColor = .white
            dialogBox.layer.cornerRadius = 5
        }
        
        static func apply(titleLabel: UILabel) {

            titleLabel.textColor = .black
        }
        
        static func apply(cancelButton: UIButton) {
            
        }
        
        static func apply(activityIndicator: UIActivityIndicatorView) {
            
            activityIndicator.style = .medium
        }
    }
}
