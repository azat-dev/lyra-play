//
//  EditDictionaryItemPresentationData.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 12.09.2022.
//

import Foundation

public struct EditDictionaryItemPresentationData: Equatable {

    // MARK: - Properties

    public var title: String
    public var originalText: String
    public var translation: String
    public var originalTextLanguage: String
    public var translationTextLanguage: String

    // MARK: - Initializers

    public init(
        title: String,
        originalText: String,
        translation: String,
        originalTextLanguage: String,
        translationTextLanguage: String
    ) {

        self.title = title
        self.originalText = originalText
        self.translation = translation
        self.originalTextLanguage = originalTextLanguage
        self.translationTextLanguage = translationTextLanguage
    }
}
