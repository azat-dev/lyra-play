//
//  LemmatizerImpl.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 23.01.23.
//

import Foundation
import NaturalLanguage

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
