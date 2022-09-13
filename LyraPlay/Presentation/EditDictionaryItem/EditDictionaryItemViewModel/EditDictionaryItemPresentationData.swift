//
//  EditDictionaryItemPresentationData.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 12.09.2022.
//

import Foundation

public struct EditDictionaryItemPresentationData: Equatable {

    // MARK: - Properties

    public var originalText: String
    public var translation: String
    public var originalTextLanguage: String
    public var translationTextLanguage: String

    // MARK: - Initializers

    public init(
        originalText: String,
        translation: String,
        originalTextLanguage: String,
        translationTextLanguage: String
    ) {

        self.originalText = originalText
        self.translation = translation
        self.originalTextLanguage = originalTextLanguage
        self.translationTextLanguage = translationTextLanguage
    }
}
