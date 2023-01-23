//
//  TextSplitterImpl.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 23.01.23.
//

import Foundation
import NaturalLanguage

public final class TextSplitterImpl: TextSplitter {
    
    // MARK: - Properties
    
    public init() {}
    
    // MARK: - Methods
    
    public func split(text: String) -> [TextComponent] {
        
        var result = [TextComponent]()
        
        let tagger = NLTagger(tagSchemes: [.tokenType])
        tagger.string = text
        
        tagger.enumerateTags(
            in: (text.startIndex..<text.endIndex),
            unit: .word,
            scheme: .tokenType
        ) { tag, range in

            guard let tag = tag else {
                return true
            }
            
            var itemType: TextComponent.ComponentType
            
            switch tag {
            case .word:
                itemType = .word
            case .punctuation, .other:
                itemType = .specialCharacter
            case .whitespace:
                itemType = .space
            default:
                itemType = .specialCharacter
            }
            
            result.append(
                .init(
                    type: itemType,
                    range: range
                )
            )
            return true
        }
        
        return result
    }
}
