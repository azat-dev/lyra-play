//
//  AttachingSubtitlesProgressViewController+Layout.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 10.09.22.
//

import Foundation
import UIKit

extension AttachingSubtitlesProgressViewController {
    
    final class Layout {
        
        static func apply(
            view: UIView,
            dialogBox: UIView,
            titleLabel: UILabel,
            cancelButton: UIButton
        ) {
            
            view.translatesAutoresizingMaskIntoConstraints = false
            dialogBox.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                
                dialogBox.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                dialogBox.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                
                dialogBox.widthAnchor.constraint(equalToConstant: 200),
                dialogBox.heightAnchor.constraint(equalToConstant: 200),
            ])
        }
    }
}

