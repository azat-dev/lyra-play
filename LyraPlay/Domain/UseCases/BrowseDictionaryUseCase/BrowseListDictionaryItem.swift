//
//  BrowseListDictionaryItem.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 30.08.2022.
//

import Foundation

public struct BrowseListDictionaryItem: Equatable {

    // MARK: - Properties

    public var id: UUID
    public var originalText: String
    public var translatedText: String

    // MARK: - Initializers

    public init(
        id: UUID,
        originalText: String,
        translatedText: String
    ) {

        self.id = id
        self.originalText = originalText
        self.translatedText = translatedText
    }
}

extension BrowseListDictionaryItem {
    
    init(_ item: DictionaryItem) {
        
        id = item.id!
        originalText = item.originalText
        translatedText = item.translations.first?.text ?? ""
    }
}
