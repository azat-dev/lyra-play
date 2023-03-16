//
//  JsonSubtitlesParser.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 16.03.23.
//

import Foundation

import Foundation
import SwiftWebVTT

private struct JSONSubtitles: Codable {
    
    let events: [JSONSubtitlesEvent]
}

private struct JSONSubtitlesEvent: Codable {
    
    let tStartMs: Double
    let dDurationMs: Double?
    let segs: [JSONSubtitlesEventSegment]?
}

private struct JSONSubtitlesEventSegment: Codable {
    let utf8: String
}

public final class JsonSubtitlesParser: SubtitlesParser {
    
    // MARK: - Properties

    private let textSplitter: TextSplitter

    // MARK: - Initializers

    public init(textSplitter: TextSplitter) {

        self.textSplitter = textSplitter
    }
}

// MARK: - Output Methods

extension JsonSubtitlesParser {

    public func parse(_ text: String, fileName: String) async -> Result<Subtitles, SubtitlesParserError> {
        
        let decoder = JSONDecoder()
        
        guard
            let data = text.data(using: .utf8)
        else {
            return .failure(.internalError(nil))
        }
        
        let parsedData = try! decoder.decode(JSONSubtitles.self, from: data)
        
        var items = [Subtitles.Sentence]()
        
        for event in parsedData.events {
            
            guard let segments = event.segs else {
                continue
            }
            
            var text = ""
            
            for segment in segments {
                
                text += segment.utf8
            }
            
            items.append(
                .init(
                    startTime: event.tStartMs / 1000,
                    duration: (event.dDurationMs ?? 0) / 1000,
                    text: text,
                    components: textSplitter.split(text: text)
                )
            )
        }

        let subtitles = Subtitles(
            duration: (parsedData.events.first?.dDurationMs ?? 0) / 1000,
            sentences: items
        )
        
        return .success(subtitles)
    }
}
