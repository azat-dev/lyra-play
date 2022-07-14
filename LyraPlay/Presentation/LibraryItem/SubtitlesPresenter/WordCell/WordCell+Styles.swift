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
        
        static func apply(label: UILabel) {
            
            label.textColor = .white
        }
        
        static func apply(activeLabel: UILabel) {
            activeLabel.textColor = .white
        }
    }
}
