//
//  Lemmatizer.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 22.07.22.
//

import Foundation
import NaturalLanguage

// MARK: - Interfaces

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

public protocol Lemmatizer {
    
    func lemmatize(text: String) -> [LemmaItem]
}

// MARK: - Implementations

public final class LemmatizerImpl: Lemmatizer {
    
    public init() {}
    
    public func lemmatize(text: String) -> [LemmaItem] {

        var items = [LemmaItem]()
        
        let tagger = NLTagger(tagSchemes: [.lemma])
        tagger.string = text
        
        tagger.enumerateTags(
            in: (text.startIndex..<text.endIndex),
            unit: .word,
            scheme: .lemma
        ) { tag, range in
            
            guard let lemma = tag?.rawValue else {
                return true
            }
            
            items.append(
                .init(
                    lemma: lemma,
                    range: range
                )
            )
            
            return true
        }
        
        return items
    }
}
