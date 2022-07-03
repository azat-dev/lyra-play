//
//  UIFont+Utils.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 03.07.22.
//

import Foundation
import UIKit

extension UIFont {
    
    static func preferredFont(forTextStyle style: TextStyle, weight: Weight) -> UIFont {
        
        let metrics = UIFontMetrics(forTextStyle: style)
        let descriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: style)
        let font = UIFont.systemFont(ofSize: descriptor.pointSize, weight: weight)
        
        return metrics.scaledFont(for: font)
    }
    
    static func preferredFont(name: String, forTextStyle style: TextStyle) -> UIFont {
        
        let metrics = UIFontMetrics(forTextStyle: style)
        let descriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: style)
        let font = UIFont(name: name, size: descriptor.pointSize)!
        
        return metrics.scaledFont(for: font)
    }
}
