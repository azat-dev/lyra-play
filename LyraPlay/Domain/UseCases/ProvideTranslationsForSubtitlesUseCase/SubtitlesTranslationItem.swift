//
//  SubtitlesTranslationItem.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 01.09.2022.
//

import Foundation

public struct SubtitlesTranslationItem: Equatable {

    // MARK: - Properties

    public var dictionaryItemId: UUID
    public var translationId: UUID
    public var originalText: String
    public var translatedText: String

    // MARK: - Initializers

    public init(
        dictionaryItemId: UUID,
        translationId: UUID,
        originalText: String,
        translatedText: String
    ) {

        self.dictionaryItemId = dictionaryItemId
        self.translationId = translationId
        self.originalText = originalText
        self.translatedText = translatedText
    }
    
    public var originalTextLanguage: String {
        "en_US"
    }
    
    public var translatedTextLanguage: String {
        "ru_RU"
    }
}
