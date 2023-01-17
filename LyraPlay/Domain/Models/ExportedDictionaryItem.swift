//
//  ExportedDictionaryItem.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 16.01.23.
//

import Foundation

public struct ExportedDictionaryItem: Codable, Equatable {
    
    // MARK: - Properties
    
    public var original: String
    public var translations: [String]
    
    // MARK: - Initializers
    
    public init(original: String, translations: [String]) {
        
        self.original = original
        self.translations = translations
    }
}
