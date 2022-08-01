//
//  LyricsParser.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 06.07.22.
//

import Foundation
import simd

extension String {
    func substring(with nsrange: NSRange) -> Substring? {
        
        guard let range = Range(nsrange, in: self) else { return nil }
        return self[range]
    }
}


public class LyricsParser: SubtitlesParser {
    
    private enum ParsedLine {
        
        case sentence(Subtitles.Sentence)
        case lengthTag(duration: TimeInterval)
        case empty
    }
    
    private struct ParsedTimeMarkTag: Equatable {
        
        var startTime: Double
        var rangeWithText: Range<String.Index>
        var tagRange: Range<String.Index>
        var followingTextRange: Range<String.Index>
    }
    
    private var textSplitter: TextSplitter
    
    public init(textSplitter: TextSplitter) {
        
        self.textSplitter = textSplitter
    }
    
    private static func parseTimeMarksTags(text: String) -> [ParsedTimeMarkTag] {
        
        let range = NSRange((text.startIndex..<text.endIndex), in: text)
        let regex = try! NSRegularExpression(pattern: #"(?<tag><(?<startTime>\d+:[0-5][0-9](\.(\d){1,3})?)>)((?<text>.*?)(?=(\n|$|(<\d+:[0-5][0-9](\.(\d){1,3})?>))))?"#)
        
        let matches = regex.matches(in: text, range: range)
        
        let parser = DurationParser()
        var items = [ParsedTimeMarkTag]()
        
        for match in matches {
            
            let tagRange = match.range(withName: "tag")
            let startTimeRange = match.range(withName: "startTime")
            let textRange = match.range(withName: "text")
            
            let timeMarkText = String(text.substring(with: startTimeRange)!)
            
            guard
                let startTime = parser.parse(timeMarkText)
            else {
                
                continue
            }
            
            items.append(
                .init(
                    startTime: startTime,
                    rangeWithText: Range(match.range, in: text)!,
                    tagRange: Range(tagRange, in: text)!,
                    followingTextRange: Range(textRange, in: text)!
                )
            )
        }
        
        return items
    }
    
    private static func append(text: inout String, character: Character) {
        
        if character.isWhitespace &&
            (text.isEmpty || text.hasSuffix(" ")) {
            
            return
        }
        
        text.append(character)
    }
    
    private static func parseLineText(text: String) -> (cleanedText: String, timeMarks: [Subtitles.TimeMark]) {
        
        let tags = parseTimeMarksTags(text: text)
        
        var timeMarks = [Subtitles.TimeMark]()
        var cleanedText = ""
        
        var currentTag: ParsedTimeMarkTag? = nil
        var timeMarkStart: String.Index? = nil
        
        let appendTimeMark = { () -> Void in
            
            guard
                let timeMarkStart = timeMarkStart,
                let currentTag = currentTag,
                let lastIndex = cleanedText.lastIndex(where: { !$0.isWhitespace && !$0.isNewline }),
                timeMarkStart < lastIndex
            else {
                
                return
            }

            let range = (timeMarkStart..<text.index(after: lastIndex))
            
            if range.isEmpty {
               return
            }
            
            timeMarks.append(
                .init(
                    startTime: currentTag.startTime,
                    duration: nil,
                    range: range
                )
            )
        }
        
        for index in text.indices {
            
            let character = text[index]
            let newTag = tags.first { $0.rangeWithText.contains(index) }
        
            if newTag != currentTag {

                appendTimeMark()
                
                timeMarkStart = nil
                currentTag = newTag
            }
            
            
            guard let currentTag = currentTag else {
                
                append(text: &cleanedText, character: character)
                continue
            }
            
            if currentTag.tagRange.contains(index) {
                
                continue
            }
            
            if currentTag.followingTextRange.contains(index) {
                
                append(text: &cleanedText, character: character)

                if timeMarkStart == nil && !character.isNewline && !character.isWhitespace{
                    
                    timeMarkStart = cleanedText.index(before: cleanedText.endIndex)
                }
                
                continue
            }
            
            append(text: &cleanedText, character: character)
        }
        
        appendTimeMark()
        return (cleanedText, timeMarks)
    }
    
    private func parseLineWithText(match: NSTextCheckingResult, line: String) async -> ParsedLine {
        

        let durationRange = match.range(withName: "duration")
        let textRange = match.range(withName: "text")
        
        guard let durationSubstring = line.substring(with: durationRange) else {
            return .empty
        }
        
        let durationText = String(durationSubstring)
        let parser = DurationParser()
        
        guard
            let startTime = parser.parse(durationText)
        else {
            return .empty
        }
        
        var text = ""
        
        if let textSubstring = line.substring(with: textRange) {
            
            text = String(textSubstring)
        }
        
        let (cleanedText, timeMarks) = Self.parseLineText(text: text)
        
        if cleanedText.isEmpty {
            return .empty
        }
        
        return .sentence(
            .init(
                startTime: startTime,
                duration: nil,
                text: cleanedText,
                timeMarks: timeMarks.isEmpty ? nil : timeMarks,
                components: textSplitter.split(text: cleanedText)
            )
        )
    }
    
    private func parseTagLine(match: NSTextCheckingResult, line: String) async -> ParsedLine {
        
        let valueRange = match.range(withName: "tagText")
        let tagNameRange = match.range(withName: "tagName")
        
        guard
            let tagSubstring = line.substring(with: tagNameRange),
            let valueSubstring = line.substring(with: valueRange)
        else {
            return .empty
        }
        
        if tagSubstring == "length" {
           
            let parser = DurationParser()
            
            guard
                let duration = parser.parse(String(valueSubstring))
            else {
                return .empty
            }
            
            return .lengthTag(duration: duration)
        }
        
        return .empty
    }
    
    private func parseLine(_ line: String) async -> ParsedLine {
        
        let range = NSRange((line.startIndex..<line.endIndex), in: line)
        
        let tagRegex = try! NSRegularExpression(pattern: #"^\s*\[(?<tagName>[a-zA-Z][^:]*)\s*:\s*(?<tagText>.*)\s*\]"#)
        
        let textLineRegex = try! NSRegularExpression(pattern: #"^\s*\[(?<duration>\d+:[0-5][0-9](\.(\d){1,3})?)\](?<text>.*)"#)
        
        if let tagMatch = tagRegex.firstMatch(in: line, range: range) {
            
            return await parseTagLine(match: tagMatch, line: line)
        }
        
        if let textMatch = textLineRegex.firstMatch(in: line, range: range) {
            
            return await parseLineWithText(match: textMatch, line: line)
        }
        
        return .empty
    }
    
    public func parse(_ text: String) async -> Result<Subtitles, SubtitlesParserError> {
        
        var duration: TimeInterval = 0.0
        var sentences = [Subtitles.Sentence]()
        let splittedText = text.split(separator: "\n")
        
        
        for line in splittedText {
            
            let parsedLine = await parseLine(String(line))
            
            switch parsedLine {
            case .sentence(let sentence):
                sentences.append(sentence)
            case .lengthTag(duration: let durationFromTag):
                duration = durationFromTag
                break
            case .empty:
                break
            }
        }
        
        let result = Subtitles(duration: duration, sentences: sentences)
        return .success(result)
    }
}
