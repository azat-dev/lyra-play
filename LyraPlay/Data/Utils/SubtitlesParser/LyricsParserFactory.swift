//
//  LyricsParserFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 01.09.2022.
//

import Foundation

public final class LyricsParserFactory: SubtitlesParserFactory {

    // MARK: - Properties

    private let textSplitterFactory: TextSplitterFactory

    // MARK: - Initializers

    public init(textSplitterFactory: TextSplitterFactory) {

        self.textSplitterFactory = textSplitterFactory
    }

    // MARK: - Methods

    public func create() -> SubtitlesParser {

        let textSplitter = textSplitterFactory.create()
        return LyricsParser(textSplitter: textSplitter)
    }
}
