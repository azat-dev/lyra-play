//
//  EditDictionaryItemViewController+Layout.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 12.09.22.
//

import Foundation
import UIKit

extension EditDictionaryItemViewController {
    
    final class Layout {
    
        static let originalTextGroupPadding = UIEdgeInsets(
            top: 15,
            left: 15,
            bottom: 15,
            right: 15
        )
        
        static func apply(
            view: UIView,
            activityIndicator: UIActivityIndicatorView,
            contentGroup: UIView,
            originalTextGroup: UIView,
            originalLanguageLabel: UILabel,
            originalTextInput: UITextField,
            translationTextInput: UITextField
        ) {
            
            activityIndicator.constraintToCenter(of: view)

            contentGroup.constraintTo(view: view)
            
            originalTextInput.translatesAutoresizingMaskIntoConstraints = false
            
            originalTextGroup.constraintToHorizontalEdges(
                of: contentGroup,
                leftMargin: 10,
                rightMargin: 10
            )
            
            originalLanguageLabel.constraintToHorizontalEdges(
                of: originalTextGroup,
                leftMargin: originalTextGroupPadding.left,
                rightMargin: originalTextGroupPadding.right
            )
            
            originalTextInput.constraintToHorizontalEdges(
                of: originalTextGroup,
                leftMargin: originalTextGroupPadding.left,
                rightMargin: originalTextGroupPadding.right
            )
            
            NSLayoutConstraint.activate([
                
                originalTextGroup.topAnchor.constraint(equalTo: contentGroup.topAnchor, constant: 100),
                originalTextGroup.topAnchor.constraint(equalTo: contentGroup.bottomAnchor, constant: -10),
            
                originalLanguageLabel.topAnchor.constraint(
                    equalTo: originalTextGroup.topAnchor,
                    constant: originalTextGroupPadding.top
                ),
                
                originalTextInput.topAnchor.constraint(equalTo: originalLanguageLabel.bottomAnchor, constant: 10),
                
                originalTextInput.bottomAnchor.constraint(
                    equalTo: originalTextGroup.bottomAnchor,
                    constant: -originalTextGroupPadding.bottom
                ),
            ])
        }
    }
}

