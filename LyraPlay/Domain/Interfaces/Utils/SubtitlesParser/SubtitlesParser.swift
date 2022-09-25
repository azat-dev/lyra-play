//
//  SubtitlesParser.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 01.09.2022.
//

import Foundation

public enum SubtitlesParserError: Error {

    case internalError(Error?)
}

public protocol SubtitlesParserInput {}

public protocol SubtitlesParserOutput {

    func parse(_ text: String, fileName: String) async -> Result<Subtitles, SubtitlesParserError>
}

public protocol SubtitlesParser: SubtitlesParserOutput, SubtitlesParserInput {}
