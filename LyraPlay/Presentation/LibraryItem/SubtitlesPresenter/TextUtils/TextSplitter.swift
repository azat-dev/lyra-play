//
//  TextSplitter.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 17.07.22.
//

import Foundation

// MARK: - Interfaces

public protocol TextSplitter {
    
    func split(text: String) -> [TextComponent]
}

// MARK: - Implementations

public final class DefaultTextSplitter: TextSplitter {
    
    public init() {}
    
    public func split(text: String) -> [TextComponent] {
        
        var items = [TextComponent]()

        var currentWord = ""
        var currentWordStart: String.Index? = nil
        
        let appendCurrentWord = { (lastIndex: String.Index) -> Void in
            
            guard let wordStart = currentWordStart else {
                return
            }
            
            
            let word = TextComponent(
                type: .word,
                range: (wordStart...lastIndex),
                text: currentWord
            )
            
            items.append(word)
            currentWordStart = nil
            currentWord = ""
        }
        
        for index in text.indices {

            let character = text[index]
            
            if character.isNewline {
                
                appendCurrentWord(text.index(before: index))
                
                let space = TextComponent(
                    type: .newLine,
                    range: (index...index),
                    text: String(character)
                )
                
                items.append(space)
                continue
            }
            
            if character.isWhitespace {
                
                appendCurrentWord(text.index(before: index))
                
                let space = TextComponent(
                    type: .space,
                    range: (index...index),
                    text: String(character)
                )
                
                items.append(space)
                continue
            }
            
            if character == "," {
                
                appendCurrentWord(text.index(before: index))
                
                let specialCharacter = TextComponent(
                    type: .specialCharacter,
                    range: (index...index),
                    text: String(character)
                )
                
                items.append(specialCharacter)
                continue
            }
            
            
            if character == "-" && currentWordStart != nil {
                
                currentWord.append(character)
                continue
            }
            
            if !(character.isLetter || character.isNumber) {
                
                appendCurrentWord(text.index(before: index))
                
                let specialCharacter = TextComponent(
                    type: .specialCharacter,
                    range: index...index,
                    text: String(character)
                )
                items.append(specialCharacter)
                continue
            }
            
            if currentWordStart == nil {
                currentWordStart = index
                currentWord = ""
            }
            
            currentWord.append(character)
        }
        
        if !text.isEmpty {
            appendCurrentWord(text.index(before: text.endIndex))
        }
        
        return items
    }
}
