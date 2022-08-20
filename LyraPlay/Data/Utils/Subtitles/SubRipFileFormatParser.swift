//
//  SubRipFileFormatParser.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 20.08.22.
//

import Foundation

public class SubRipFileFormatParser: SubtitlesParser {
    
    private var textSplitter: TextSplitter
    
    public init(textSplitter: TextSplitter) {
        
        self.textSplitter = textSplitter
    }
    
    public func parse(_ text: String) async -> Result<Subtitles, SubtitlesParserError> {
        return .failure(.internalError(nil))
    }
}
