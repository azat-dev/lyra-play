//
//  Dictionary+Helpers.swift
//  LyraPlayTests
//
//  Created by Azat Kaiumov on 19.08.22.
//

import Foundation
import LyraPlay

extension TranslationItem {
    
    static func anyTranslationId() -> UUID {
        return UUID()
    }
    
    static func anyTranslation(text: String = "translation", position: TranslationItemPosition? = nil) -> TranslationItem {
        return TranslationItem(
            id: anyTranslationId(),
            text: text,
            position: position
        )
    }
}

extension DictionaryItem {
    
    static func anyNewDictionaryItem(suffix: String = "") -> DictionaryItem {
        
        return DictionaryItem(
            id: nil,
            originalText: "originalText" + suffix,
            lemma: "lemma" + suffix,
            language: "English" + suffix,
            translations: [
                .anyTranslation(text: "text1" + suffix),
                .anyTranslation(text: "text2" + suffix, position: .init(sentenceIndex: 0, textRange: 0..<10))
            ]
        )
    }
    
    static func anyExistingDictonaryItem() -> DictionaryItem {
        
        var item = anyNewDictionaryItem()
        item.id = UUID()
        
        return item
    }
}
