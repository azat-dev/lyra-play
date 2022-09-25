//
//  PromptDialogViewController+Styles.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 21.09.22.
//

import Foundation
import UIKit

extension PromptDialogViewController {
    
    final class Styles {
        
        // MARK: - Properties
        
        private static let cornerRadius: CGFloat = 10
        private static let separatorColor = UIColor(named: "Color.Separator")
        
        // MARK: - Methods
        
        static func apply(contentView: UIView) {
            
            contentView.backgroundColor = .black.withAlphaComponent(0.48)
        }
        
        static func apply(dialogView: UIView) {
            
            dialogView.backgroundColor = .secondarySystemBackground
            dialogView.layer.cornerRadius = cornerRadius
        }
        
        static func apply(textField: UITextField) {

            textField.borderStyle = .roundedRect
            textField.layer.borderColor = UIColor.separator.cgColor
            textField.layer.borderWidth = 0.5
            textField.layer.cornerRadius = 5
        }
        
        static func apply(messageLabel: UILabel) {

            messageLabel.textAlignment = .center
            messageLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        }
        
        static func apply(errorLabel: UILabel) {

            errorLabel.textAlignment = .center
            errorLabel.textColor = .systemRed
            errorLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        }
        
        static func apply(separator: UIView) {
            
            separator.backgroundColor = .separator
        }
        
        static func apply(cancelButton: UIButton) {
            
            cancelButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: .headline)
            cancelButton.setTitleColor(.systemBlue, for: .normal)
        }
        
        static func apply(submitButton: UIButton) {
            
            submitButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: .headline)
            submitButton.setTitleColor(.systemBlue, for: .normal)
        }
        
        static func apply(submitButtonProcessing submitButton: UIButton) {
            
            apply(submitButton: submitButton)
            submitButton.setTitleColor(.clear, for: .normal)
        }
        
        static func apply(activityIndicator: UIActivityIndicatorView) {
            
            activityIndicator.hidesWhenStopped = true
        }
    }
}
