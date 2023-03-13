//
//  LyricsParser.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 01.09.2022.
//

import Foundation
import SwiftWebVTT

public final class VttParser: SubtitlesParser {

    // MARK: - Properties

    private let textSplitter: TextSplitter

    // MARK: - Initializers

    public init(textSplitter: TextSplitter) {

        self.textSplitter = textSplitter
    }
}

// MARK: - Output Methods

extension VttParser {

    public func parse(_ text: String, fileName: String) async -> Result<Subtitles, SubtitlesParserError> {
        
        let parser = WebVTTParser(string: text)
        var sentences = [Subtitles.Sentence]()
        
        do {
            
            let webVTT = try parser.parse()
            
            
            for cue in webVTT.cues {
                
                let text = cue.text.decodingHTMLEntities()
                
                let sentence = Subtitles.Sentence(
                    startTime: cue.timeStart,
                    duration: cue.timeEnd - cue.timeStart,
                    text: text,
                    components: textSplitter.split(text: text)
                )
                
                sentences.append(sentence)
            }

            let subtitles = Subtitles(
                duration: webVTT.cues.last?.timeEnd ?? 0,
                sentences: sentences
            )
            
            return .success(subtitles)
            
        } catch {
            return .failure(.internalError(error))
        }
    }
}
