//
//  JsonSubtitlesParserFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 16.03.23.
//

import Foundation

public final class JsonSubtitlesParserFactory: SubtitlesParserFactory {

    // MARK: - Properties

    private let textSplitterFactory: TextSplitterFactory

    // MARK: - Initializers

    public init(textSplitterFactory: TextSplitterFactory) {

        self.textSplitterFactory = textSplitterFactory
    }

    // MARK: - Methods

    public func make() -> SubtitlesParser {

        let textSplitter = textSplitterFactory.make()
        return JsonSubtitlesParser(textSplitter: textSplitter)
    }
}
