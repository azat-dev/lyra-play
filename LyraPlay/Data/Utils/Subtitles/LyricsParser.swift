//
//  LyricsParser.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 06.07.22.
//

import Foundation

public class LyricsParser: SubtitlesParser {
    
    public init() {}
    
    public func parse(_ text: String) async -> Result<Subtitles, SubtitlesParserError> {
        
        let splittedText = text.split(separator: "\n")
        
        let sentences: [Subtitles.Sentence] = []
        let result = Subtitles(sentences: sentences)
        
        return .success(result)
    }
}
