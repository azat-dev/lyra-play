//
//  TextSplitter.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 17.07.22.
//

import Foundation
import NaturalLanguage

// MARK: - Interfaces

public protocol TextSplitter {
    
    func split(text: String) -> [TextComponent]
}

// MARK: - Implementations

public final class TextSplitterImpl: TextSplitter {
    
    public init() {}
    
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
