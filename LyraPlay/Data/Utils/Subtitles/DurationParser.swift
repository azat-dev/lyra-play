//
//  DurationParser.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 06.07.22.
//

import Foundation


final public class DurationParser {

    private let millisecondsSeparator: String
    
    public init(millisecondsSeparator: String = ".") {
        
        self.millisecondsSeparator = millisecondsSeparator
    }
    
    private static func parseMilliseconds(text: String) -> Double? {
        
        guard text.count <= 3 else {
            return nil
        }
        
        guard let parsedNumber = Double(text) else {
            return nil
        }
        
        return parsedNumber * pow(10.0, Double(3 - text.count))
    }
    
    public func parse(_ durationText: String) -> Double? {
        
        guard !durationText.isEmpty else {
            return nil
        }

        let splittedText = durationText.components(separatedBy: millisecondsSeparator)
        
        guard
            splittedText.count <= 2,
            let timeString = splittedText.first
        else {
            return nil
        }
        
        var milliseconds = 0.0
        
        if splittedText.count > 1 {
           
            let millisecondsText = splittedText[1]
            
            guard let parsedMilliseconds = Self.parseMilliseconds(text: millisecondsText) else {
                return nil
            }
            
            milliseconds = parsedMilliseconds
        }

        let parts = timeString.components(separatedBy: ":")
        var seconds = 0.0
        
        for (index, part) in parts.reversed().enumerated() {
            
            guard let parsedNumber = Double(part) else {
                return nil
            }
            
            seconds += parsedNumber * pow(60.0, Double(index))
        }
        
        
        return (seconds * 1000 + milliseconds) / 1000
    }
}
