//
//  PromptDialogViewController+Layout.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 21.09.22.
//

import Foundation
import UIKit

extension PromptDialogViewController {
    
    final class Layout {
        
        // MARK: - Properties
        
        static let dialogViewPadding = UIEdgeInsets(top: 20, left: 15, bottom: 10, right: 15)
        static let dialogWidth: CGFloat = 270
        
        // MARK: - Methods
        
        static func applyButtonWithActivityIndicator(
            submitButton: UIButton,
            activityIndicator: UIActivityIndicatorView
        ) {

            activityIndicator.constraintToCenter(of: submitButton)
        }
        
        static func applyButtonsGroupContent(
            buttonsGroup: UIStackView,
            horizontalSeparator: UIView,
            verticalSeparator: UIView,
            cancelButton: UIButton,
            submitButton: UIButton
        ) {
            
            horizontalSeparator.disableAutoConstraints()
            verticalSeparator.disableAutoConstraints()

            buttonsGroup.axis = .horizontal
            buttonsGroup.distribution = .fillEqually
            
            horizontalSeparator.constraintToHorizontalEdges(of: buttonsGroup)

            NSLayoutConstraint.activate([
            
                buttonsGroup.heightAnchor.constraint(equalToConstant: 44),
                
                horizontalSeparator.topAnchor.constraint(equalTo: buttonsGroup.topAnchor),
                horizontalSeparator.heightAnchor.constraint(equalToConstant: 0.5),
                
                verticalSeparator.widthAnchor.constraint(equalToConstant: 0.5),
                verticalSeparator.centerXAnchor.constraint(equalTo: buttonsGroup.centerXAnchor),

                verticalSeparator.topAnchor.constraint(equalTo: buttonsGroup.topAnchor),
                verticalSeparator.bottomAnchor.constraint(equalTo: buttonsGroup.bottomAnchor)
            ])
        }
        
        static func applyTextFieldGroupContent(
            textFieldGroup: UIStackView,
            textField: UITextField,
            errorTextLabel: UILabel
        ) {
            
            textFieldGroup.axis = .vertical
            textFieldGroup.distribution = .fill

            textFieldGroup.spacing = 10

            textField.setContentHuggingPriority(.defaultHigh, for: .vertical)
            errorTextLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)
        }
        
        static func applyDialogViewContent(
            dialogView: UIView,
            messageLabel: UILabel,
            textFieldGroup: UIStackView,
            buttonsGroup: UIStackView
        ) {
            
            messageLabel.constraintToHorizontalEdges(
                of: dialogView,
                leftMargin: dialogViewPadding.left,
                rightMargin: dialogViewPadding.right
            )

            textFieldGroup.constraintToHorizontalEdges(
                of: dialogView,
                leftMargin: dialogViewPadding.left,
                rightMargin: dialogViewPadding.right
            )

            buttonsGroup.constraintToHorizontalEdges(of: dialogView)
            
            messageLabel
                .constraintToBottom(view: textFieldGroup, spacing: 20)
                .constraintToBottom(view: buttonsGroup, spacing: 20)
                
            dialogView.widthAnchor
                .constraint(equalToConstant: dialogWidth)
                .activated()
            
            messageLabel.topAnchor
                .constraint(equalTo: dialogView.topAnchor, constant: dialogViewPadding.top)
                .activated()
            
            buttonsGroup.bottomAnchor
                .constraint(equalTo: dialogView.bottomAnchor)
                .activated()
            
            buttonsGroup.heightAnchor
                .constraint(equalToConstant: 44)
                .activated()
        }
        
        static func applyDialogViewPosition(
            container: UIView,
            dialogView: UIView
        ) {
            
            dialogView.disableAutoConstraints()
            dialogView.constraintToCenter(of: container)
        }
        
        static func applyAdjustKeyboardOffset(
            container: UIView,
            adjustKeyboarView: UIView
        ) -> NSLayoutConstraint {
            
            
            adjustKeyboarView.disableAutoConstraints()
            
            return adjustKeyboarView.heightAnchor
                .constraint(equalToConstant: 0)
                .activated()
        }
        
        static func applyContentViewContent(
            contentView: UIView,
            container: UIView,
            dialogView: UIView,
            adjustKeyboarView: UIView
        ) {

            container.disableAutoConstraints()
            adjustKeyboarView.disableAutoConstraints()
            
            container.constraintToHorizontalEdges(of: contentView)

            container.topAnchor
                .constraint(equalTo: contentView.topAnchor)
                .activated()
            
            container
                .constraintToBottom(view: adjustKeyboarView)

            adjustKeyboarView.constraintToHorizontalEdges(of: contentView)
            adjustKeyboarView.bottomAnchor
                .constraint(equalTo: contentView.bottomAnchor)
                .activated()
        }
    }
}

