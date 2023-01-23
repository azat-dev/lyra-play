//
//  LemmaItem.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 23.01.23.
//

import Foundation

public struct LemmaItem {
    
    public var lemma: String
    public var range: Range<String.Index>
    
    public init(
        lemma: String,
        range: Range<String.Index>
    ) {
        
        self.lemma = lemma
        self.range = range
    }
}
