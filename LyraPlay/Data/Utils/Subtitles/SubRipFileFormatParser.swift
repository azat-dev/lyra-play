//
//  SubRipFileFormatParser.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 20.08.22.
//

import Foundation

public class SubRipFileFormatParser: SubtitlesParser {
    
    private struct ParsedTime: Equatable {
        
        var startTime: Double
        var endTime: Double
    }
    
    private var textSplitter: TextSplitter
    
    public init(textSplitter: TextSplitter) {
        
        self.textSplitter = textSplitter
    }
}

extension SubRipFileFormatParser {
    
    private func parseTime(text: String) -> ParsedTime? {
        
        let range = NSRange((text.startIndex..<text.endIndex), in: text)
        
        let regEx = try! NSRegularExpression(pattern: #"\s*(?<startTime>\d\d:\d\d:\d\d,\d\d\d)\s*-->\s*(?<endTime>\d\d:\d\d:\d\d,\d\d\d)"#)
        let matches = regEx.matches(in: text, range: range)
        
        guard let match = matches.first else {
            return nil
        }
        
        let startTimeRange = match.range(withName: "startTime")
        let endTimeRange = match.range(withName: "endTime")
        
        let durationParser = DurationParser(millisecondsSeparator: ",")
        let startTimeText = String(text.substring(with: startTimeRange)!)
        let endTimeText = String(text.substring(with: endTimeRange)!)
        
        guard
            let startTime = durationParser.parse(startTimeText),
            let endTime = durationParser.parse(endTimeText)
        else {
            return nil
        }
        
        return .init(startTime: startTime, endTime: endTime)
    }
    
    private func parsePosition(text: String) -> Int? {
        
        let range = NSRange((text.startIndex..<text.endIndex), in: text)
        
        let regEx = try! NSRegularExpression(pattern:  #"\s*(?<position>\d+)\s*"#)
        let matches = regEx.matches(in: text, range: range)
        
        guard let match = matches.first else {
            return nil
        }
        
        let positionRange = match.range(withName: "position")
        let positionText = String(text.substring(with: positionRange)!)
        return Int(positionText)
    }
    
    public func parse(_ text: String, fileName: String) async -> Result<Subtitles, SubtitlesParserError> {
        
        var sentences = [Subtitles.Sentence]()
        let splittedText = text.components(separatedBy: .newlines)
        let numberOfLines = splittedText.count
        
        var currentText = ""
        var currentParsedTime: ParsedTime?
        var currentParsedPosition: Int?
        
        let appendSentence = { [weak self] () -> Void in
            
            sentences.append(
                .init(
                    startTime: currentParsedTime!.startTime,
                    duration: currentParsedTime!.endTime - currentParsedTime!.startTime,
                    text: currentText,
                    components: []
                )
            )
        }
        
        for lineIndex in 0..<numberOfLines {
            
            let line = splittedText[lineIndex].trimmingCharacters(in: .whitespacesAndNewlines)
            
            guard currentParsedPosition != nil else {
                currentParsedPosition = parsePosition(text: line)
                continue
            }
            
            guard currentParsedTime != nil else {
                currentParsedTime = parseTime(text: line)
                continue
            }
            
            guard !line.isEmpty else {
                
                appendSentence()
                
                currentText = ""
                currentParsedPosition = nil
                currentParsedTime = nil
                continue
            }
            
            if !currentText.isEmpty {
                currentText += "\n"
            }
            
            currentText += line
        }
        
        if !currentText.isEmpty && currentParsedTime != nil {
            appendSentence()
        }
        
        let lastSentence = sentences.last
        
        let result = Subtitles(
            duration: (lastSentence?.startTime ?? 0) + (lastSentence?.duration ?? 0),
            sentences: sentences
        )
        return .success(result)
    }
}
