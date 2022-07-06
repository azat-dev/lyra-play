//
//  LyricsParser.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 06.07.22.
//

import Foundation

extension String {
    func substring(with nsrange: NSRange) -> Substring? {
        
        guard let range = Range(nsrange, in: self) else { return nil }
        return self[range]
    }
}


public class LyricsParser: SubtitlesParser {
    
    private enum ParsedLine {
        
        case sentence(Subtitles.Sentence)
        case tag
        case empty
    }
    
    public init() {}
    
    private static func findTimeCodes(text: String) -> [NSTextCheckingResult] {
        
        let range = NSRange(location: 0, length: text.utf16.count)
        let regex = try! NSRegularExpression(pattern: #"<(?<duration>\d+:[0-5][0-9](\.(\d){1,3})?)>(?<text>.*?)(?=(\n|$|(<\d+:[0-5][0-9](\.(\d){1,3})?>)))"#)
        
        let timecodes = regex.matches(in: text, range: range)
        
        return timecodes
    }
    
    typealias SplitItem = (time: Double, text: String)
    
    private static func splitTextByTimeCode(text: String, match: NSTextCheckingResult) -> Result<SplitItem?, Error> {
        
        let durationRange = match.range(withName: "duration")
        let textRange = match.range(withName: "text")
        
        guard let durationSubstring = text.substring(with: durationRange) else {
            return .success(nil)
        }

        let durationText = String(durationSubstring)
        let parser = DurationParser()

        guard
            let startTime = parser.parse(durationText)
        else {
            return .success(nil)
        }
        
        guard let textSubstring = text.substring(with: textRange) else {
            return .success(nil)
        }
        
        let parsedText = String(textSubstring)
        
        let item = (
            time: startTime,
            text: parsedText.trimmingCharacters(in: .whitespacesAndNewlines)
        )
        return .success(item)
    }
    
    private static func parseText(text: String) async -> Subtitles.SentenceText  {
        

        let timecodes = findTimeCodes(text: text)
        
        guard !timecodes.isEmpty else {
            return .notSynced(text: text)
        }
        
        var items = [Subtitles.SyncedItem]()
        
        for timecodeMatch in timecodes {
            
            let splitResult = await splitTextByTimeCode(text: text, match: timecodeMatch)

            switch splitResult {
            case .failure:
                return .notSynced(text: text)
                
            case .success(let split):
                
                guard let split = split else {
                    return .notSynced(text: text)
                }
                
                items.append(
                    .init(
                        startTime: split.time,
                        duration: 0,
                        text: split.text
                    )
                )
            }
        }
        
        return .synced(items: items)
    }
    
    private static func parseLine(_ line: String) async -> ParsedLine {
        
        let range = NSRange(location: 0, length: line.utf16.count)
        
        let regex = try! NSRegularExpression(pattern: #"^\s*\[(?<duration>\d+:[0-5][0-9](\.(\d){1,3})?)\](?<text>.*)"#)
        
        let match = regex.firstMatch(in: line, range: range)
        
        guard let match = match else {
            return .empty
        }
        
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
           
            text = String(textSubstring.trimmingCharacters(in: .whitespacesAndNewlines))
        }
        
        if text.isEmpty {
            return .empty
        }
        
        return .sentence(
            .init(
                startTime: startTime,
                duration: 0,
                text: await parseText(text: text)
            )
        )
    }
    
    public func parse(_ text: String) async -> Result<Subtitles, SubtitlesParserError> {
        
        var sentences = [Subtitles.Sentence]()
        let splittedText = text.split(separator: "\n")

        for line in splittedText {
            
            let parsedLine = await Self.parseLine(String(line))
            
            switch parsedLine {
            case .sentence(let sentence):
                sentences.append(sentence)
            case .tag:
                break
            case .empty:
                break
            }
        }
        
        let result = Subtitles(sentences: sentences)
        return .success(result)
    }
}
