//
//  WordCell+Styles.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 13.07.22.
//

import Foundation
import UIKit

extension RowCell {
    
    final class Styles {
    
        static let font = Fonts.RedHatDisplay.medium.preferred(with: .title1)
        
        static func apply(commonTextView textView: UITextView) {
            
            textView.font = font
            textView.isScrollEnabled = false
            textView.isEditable = false
            textView.isSelectable = false
            textView.backgroundColor = .clear
        }
        
        static func apply(textView: UITextView) {
        
            apply(commonTextView: textView)
            
            textView.textColor = .white
            textView.layer.opacity = 0.5
        }
        
        static func apply(activeTextView textView: UITextView) {
            
            apply(commonTextView: textView)
            textView.textColor = .white
            textView.layer.opacity = 1
        }
        
        static func apply(contentView: UIView) {
            
            contentView.backgroundColor = .clear
        }
    }
}
