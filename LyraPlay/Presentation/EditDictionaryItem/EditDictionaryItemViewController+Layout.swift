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
    
        static let textGroupPadding = UIEdgeInsets(
            top: 15,
            left: 15,
            bottom: 15,
            right: 15
        )
        
        static func layoutTextGroup(
            group: UIView,
            label: UILabel,
            textInput: UITextField
        ) {
            
            group.setContentHuggingPriority(.defaultHigh, for: .vertical)
            group.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
            
            label.setContentHuggingPriority(.defaultHigh, for: .vertical)
            label.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
            
            label.constraintToHorizontalEdges(
                of: group,
                leftMargin: textGroupPadding.left,
                rightMargin: textGroupPadding.right
            )
            
            textInput.translatesAutoresizingMaskIntoConstraints = false
            textInput.constraintToHorizontalEdges(
                of: group,
                leftMargin: textGroupPadding.left,
                rightMargin: textGroupPadding.right
            )
            
            NSLayoutConstraint.activate([
            
                label.topAnchor.constraint(
                    equalTo: group.topAnchor,
                    constant: textGroupPadding.top
                ),
                
                textInput.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 10),
                
                textInput.bottomAnchor.constraint(
                    equalTo: group.bottomAnchor,
                    constant: -textGroupPadding.bottom
                ),
            ])
        }
        
        static func apply(
            view: UIView,
            activityIndicator: UIActivityIndicatorView,
            contentGroup: UIView,
            originalTextGroup: UIView,
            originalLanguageLabel: UILabel,
            originalTextInput: UITextField,
            translationTextGroup: UIView,
            translationLanguageLabel: UILabel,
            translationTextInput: UITextField
        ) {
            
            originalTextGroup.translatesAutoresizingMaskIntoConstraints = false
            translationTextGroup.translatesAutoresizingMaskIntoConstraints = false
            activityIndicator.constraintToCenter(of: view)

            contentGroup.constraintTo(view: view)
            originalTextGroup.constraintToHorizontalEdges(
                of: contentGroup,
                leftMargin: 10,
                rightMargin: 10
            )
            
            translationTextGroup.constraintToHorizontalEdges(
                of: contentGroup,
                leftMargin: 10,
                rightMargin: 10
            )

            NSLayoutConstraint.activate([

                originalTextGroup.topAnchor.constraint(equalTo: contentGroup.topAnchor, constant: 100),
                translationTextGroup.topAnchor.constraint(equalTo: originalTextGroup.bottomAnchor, constant: 20),
                translationTextGroup.topAnchor.constraint(lessThanOrEqualToSystemSpacingBelow: contentGroup.bottomAnchor, multiplier: -10),
            ])

            layoutTextGroup(
                group: originalTextGroup,
                label: originalLanguageLabel,
                textInput: originalTextInput
            )

            layoutTextGroup(
                group: translationTextGroup,
                label: translationLanguageLabel,
                textInput: translationTextInput
            )
        }
    }
}

