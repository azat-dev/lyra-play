//
//  Range+TextRange.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 06.08.22.
//

import Foundation

extension Range where Bound == Int {
    
    public static func textRange<T: StringProtocol>(from range: Range<String.Index>, in text: T) -> Range<Int> {
        
        let lowerBound = range.lowerBound.utf16Offset(in: text)
        let upperBound = range.upperBound.utf16Offset(in: text)
        
        return lowerBound..<upperBound
    }
    
    public static func textRange<T: StringProtocol>(of innerText: T, in text: T) -> Range<Int>? {
        
        guard let range = text.range(of: innerText) else {
            return nil
        }
        
        let lowerBound = range.lowerBound.utf16Offset(in: text)
        let upperBound = range.upperBound.utf16Offset(in: text)
        
        return lowerBound..<upperBound
    }
}
