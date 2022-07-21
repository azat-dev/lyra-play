//
//  SubtitlesTranslation.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 21.07.22.
//

import Foundation

public struct SubtitlesTranslation {
    
    
    public var dictionaryItemId: UUID
    public var originalText: String
    public var generalizedText: String
    public var translation: String
    
    public init(
        dictionaryItemId: UUID,
        originalText: String,
        generalizedText: String,
        translation: String
    ) {
        
        self.dictionaryItemId = dictionaryItemId
        self.originalText = originalText
        self.generalizedText = generalizedText
        self.translation = translation
    }
}
