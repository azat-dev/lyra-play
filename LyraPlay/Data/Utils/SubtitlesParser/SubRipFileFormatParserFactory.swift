//
//  SubRipFileFormatParserFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 01.09.2022.
//

import Foundation

public final class SubRipFileFormatParserFactory: SubtitlesParserFactory {

    // MARK: - Properties

    private let textSplitter: TextSplitter

    // MARK: - Initializers

    public init(textSplitter: TextSplitter) {

        self.textSplitter = textSplitter
    }

    // MARK: - Methods

    public func create() -> SubtitlesParser {

        return SubRipFileFormatParser(textSplitter: textSplitter)
    }
}