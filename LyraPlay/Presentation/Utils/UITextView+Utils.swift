//
//  UITextView+Utils.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 17.07.22.
//

import Foundation
import UIKit

extension UITextView {
    
    var textRange: NSRange {

        let start = self.offset(from: self.beginningOfDocument, to: self.beginningOfDocument)
        let length = self.offset(from: self.beginningOfDocument, to: self.endOfDocument)
        
        return NSMakeRange(start, length)
    }
}

extension UITextRange {
    
    func toNSRange(textView: UITextView) -> NSRange {
        
        let start = textView.offset(from: textView.beginningOfDocument, to: self.start)
        let length = textView.offset(from: self.start, to: self.end)
        
        return NSMakeRange(start, length)
    }
}
