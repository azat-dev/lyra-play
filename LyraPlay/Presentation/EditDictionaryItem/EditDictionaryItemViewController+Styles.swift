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
        
        static func apply(originalTextGroup group: UIView) {
            
            group.backgroundColor = colorGroupBackground
            group.layer.cornerRadius = 10
        }
        
        static func apply(originalTextInput input: UITextField) {
            
            input.backgroundColor = colorGroupBackground
            input.placeholder = "Add a word"
            input.font = fontOriginalText
            input.textColor = .white
        }
        
        static func apply(languageLabel label: UILabel) {
            
            label.text = "English"
            label.textColor = .white
            label.font = fontLabel
        }
    }
}
