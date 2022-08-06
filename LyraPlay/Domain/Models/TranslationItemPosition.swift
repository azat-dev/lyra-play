//
//  TranslationItemPosition.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 06.08.2022.
//

import Foundation

import Foundation

public struct TranslationItemPosition: Equatable {

    public var sentenceIndex: Int
    public var textRange: Range<Int>

    public init(
        sentenceIndex: Int,
        textRange: Range<Int>
    ) {

        self.sentenceIndex = sentenceIndex
        self.textRange = textRange
    }
}

extension TranslationItemPosition {
    
    public func getRange<T: StringProtocol>(in text: T) -> Range<String.Index> {
        
        let lowerBound = String.Index(utf16Offset: textRange.lowerBound, in: text)
        let upperBound = String.Index(utf16Offset: textRange.upperBound, in: text)
        
        return (lowerBound..<upperBound)
    }
}
