//
//  SubtitlesTranslation.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 01.09.2022.
//

import Foundation

public struct SubtitlesTranslation: Equatable {

    // MARK: - Properties

    public var textRange: Range<String.Index>
    public var translation: SubtitlesTranslationItem

    // MARK: - Initializers

    public init(
        textRange: Range<String.Index>,
        translation: SubtitlesTranslationItem
    ) {

        self.textRange = textRange
        self.translation = translation
    }
}