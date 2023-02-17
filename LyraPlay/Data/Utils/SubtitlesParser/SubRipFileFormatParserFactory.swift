//
//  SubRipFileFormatParserFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 01.09.2022.
//

import Foundation

public final class SubRipFileFormatParserFactory: SubtitlesParserFactory {

    // MARK: - Properties

    private let textSplitterFactory: TextSplitterFactory

    // MARK: - Initializers

    public init(textSplitterFactory: TextSplitterFactory) {

        self.textSplitterFactory = textSplitterFactory
    }

    // MARK: - Methods

    public func make() -> SubtitlesParser {

        let textSplitter = textSplitterFactory.make()
        
        return SubRipFileFormatParser(textSplitter: textSplitter)
    }
}
