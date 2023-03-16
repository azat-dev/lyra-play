//
//  EditDictionaryItemViewController+Styles.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 12.09.22.
//

import Foundation
import UIKit

extension EditDictionaryItemViewController {
    
    final class Styles {
        
        private static let colorBackground = UIColor(named: "Color.Background")
        private static let colorText = UIColor(named: "Color.Text")
        private static let colorGroupBackground = UIColor(named: "Color.Group.Background")
        
        private static let fontLabel = Fonts.RedHatDisplay.bold.preferred(with: .footnote)
        private static let fontOriginalText = Fonts.RedHatDisplay.bold.preferred(with: .title3)
        
        static func apply(contentView: UIView) {
            
            contentView.backgroundColor = colorBackground
        }
        
        static func apply(textGroup group: UIView) {
            
            group.backgroundColor = colorGroupBackground
            group.layer.cornerRadius = 10
        }
        
        static func apply(groupTextInput input: UITextField) {
            
            input.backgroundColor = colorGroupBackground
            input.font = fontOriginalText
            input.textColor = .white
            input.autocapitalizationType = .none
        }
        
        static func apply(groupLabel label: UILabel) {
            
            label.textColor = .white
            label.font = fontLabel
        }
        
        static func apply(originalTextInput input: UITextField) {
            
            apply(groupTextInput: input)
            input.placeholder = "Add a word"
            input.autocorrectionType = .yes
        }
        
        static func apply(originalLanguageLabel label: UILabel) {

            apply(groupLabel: label)
            label.text = "English"
        }
        
        static func apply(translationTextInput input: UITextField) {
            
            apply(groupTextInput: input)
            input.placeholder = "Add translation"
            input.autocorrectionType = .yes
        }
        
        static func apply(translationLanguageLabel label: UILabel) {

            apply(groupLabel: label)
            label.text = "Russian"
        }
    }
}
