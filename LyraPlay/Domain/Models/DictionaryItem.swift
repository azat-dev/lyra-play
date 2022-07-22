//
//  DictionaryItem.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 20.07.22.
//

import Foundation

public struct DictionaryItem {

    public var id: UUID?
    public var createdAt: Date?
    public var updatedAt: Date?
    public var originalText: String
    public var lemma: String
    public var language: String
    public var translations: [TranslationItem]

    public init(
        id: UUID? = nil,
        createdAt: Date? = nil,
        updatedAt: Date? = nil,
        originalText: String,
        lemma: String,
        language: String,
        translations: [TranslationItem]
    ) {
        
        self.id = id
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.originalText = originalText
        self.lemma = lemma
        self.language = language
        self.translations = translations
    }
}
