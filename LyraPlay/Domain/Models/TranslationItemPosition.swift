//
//  TranslationItemPosition.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 06.08.2022.
//

import Foundation

import Foundation

public struct TranslationItemPosition: Equatable {

    public var sentenceIndex: Int
    public var textRange: Range<Int>

    public init(
        sentenceIndex: Int,
        textRange: Range<Int>
    ) {

        self.sentenceIndex = sentenceIndex
        self.textRange = textRange
    }
}
