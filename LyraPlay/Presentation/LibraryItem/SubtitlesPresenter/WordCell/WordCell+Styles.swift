//
//  WordCell+Styles.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 13.07.22.
//

import Foundation
import UIKit

extension WordCell {
    
    final class Styles {
    
        static let font = Fonts.RedHatDisplay.medium.preferred(with: .title2)
        
        static func apply(label: UILabel) {
        
            label.font = font
            label.textColor = .white
        }
        
        static func apply(activeLabel: UILabel) {
            
            activeLabel.font = font
            activeLabel.textColor = .white
        }
    }
}
