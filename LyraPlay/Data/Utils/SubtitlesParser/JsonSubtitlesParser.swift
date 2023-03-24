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
            
            text = text.trimmingCharacters(in: .whitespacesAndNewlines)
            
            let startTime = event.tStartMs / 1000
            let duration = (event.dDurationMs ?? 0) / 1000
            
            if
                let lastItem = items.last,
                text.isEmpty &&
                lastItem.text.isEmpty
            {
                
                items[items.count - 1] = .init(
                    startTime: lastItem.startTime,
                    duration: startTime - lastItem.startTime + duration,
                    text: "",
                    components: []
                )
                continue
            }
            
            items.append(
                .init(
                    startTime: startTime,
                    duration: duration,
                    text: text,
                    components: textSplitter.split(text: text)
                )
            )
        }

        let duration = max(
            ((parsedData.events.first?.tStartMs ?? 0) + (parsedData.events.first?.dDurationMs ?? 0)) / 1000,
            ((parsedData.events.last?.tStartMs ?? 0) + (parsedData.events.last?.dDurationMs ?? 0)) / 1000
        )
        
        let subtitles = Subtitles(
            duration: duration,
            sentences: items
        )
        
        return .success(subtitles)
    }
}
