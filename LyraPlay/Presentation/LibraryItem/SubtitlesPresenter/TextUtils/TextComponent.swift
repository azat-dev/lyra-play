//
//  TextComponent.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 17.07.22.
//

import Foundation

public struct TextComponent: Equatable {

    public enum ComponentType: Equatable {
        
        case space
        case word
        case specialCharacter
    }
    
    public var type: ComponentType
    public var range: Range<String.Index>
    public var text: String
    
    public init(type: ComponentType, range: Range<String.Index>, text: String) {
        
        self.type = type
        self.range = range
        self.text = text
    }
}
