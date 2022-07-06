//
//  SubtitlesParser.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 06.07.22.
//

import Foundation

public enum SubtitlesParserError: Error {
    
    case internalError(Error?)
}

public protocol SubtitlesParser {
    
    func parse(_ text: String) async -> Result<Subtitles, SubtitlesParserError>
}
