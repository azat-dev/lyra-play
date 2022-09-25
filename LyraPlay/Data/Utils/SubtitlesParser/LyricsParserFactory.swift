//
//  LyricsParserFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 01.09.2022.
//

import Foundation

public final class LyricsParserFactory: SubtitlesParserFactory {

    // MARK: - Properties

    private let textSplitter: TextSplitter

    // MARK: - Initializers

    public init(textSplitter: TextSplitter) {

        self.textSplitter = textSplitter
    }

    // MARK: - Methods

    public func create() -> SubtitlesParser {

        return LyricsParser(textSplitter: textSplitter)
    }
}