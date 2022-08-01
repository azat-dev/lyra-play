//
//  Subtitles.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 06.07.22.
//

import Foundation


public struct Subtitles: Equatable {

    public var duration: TimeInterval
    public var sentences: [Sentence]
    
    public init(duration: TimeInterval, sentences: [Sentence]) {
        
        self.duration = duration
        self.sentences = sentences
    }

    public struct TimeMark: Equatable {
        
        public var startTime: TimeInterval
        public var duration: TimeInterval?
        public var range: Range<String.Index>
        
        public init(
            startTime: TimeInterval,
            duration: TimeInterval? = nil,
            range: Range<String.Index>
        ) {
            
            self.startTime = startTime
            self.duration = duration
            self.range = range
        }
    }
    
    public struct Sentence: Equatable {
        
        public var startTime: Double
        public var duration: Double?
        public var text: String
        public var timeMarks: [TimeMark]?
        public var components: [TextComponent]
        
        public init(
            startTime: Double,
            duration: Double? = nil,
            text: String,
            timeMarks: [TimeMark]? = nil,
            components: [TextComponent]
        ) {
            
            self.startTime = startTime
            self.duration = duration
            self.text = text
            self.timeMarks = timeMarks
            self.components = components
        }
    }
}
