//
//  SubtitlesIterator.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 11.07.22.
//

import Foundation

public struct SubtitlesItem {
    
    public var sentenceIndex: Subtitles.Sentence
    public var timeMarkInsideSentence: Subtitles.TimeMark?
    
    public init(sentence: Subtitles.Sentence, timeMarkInsideSentence: Subtitles.TimeMark? = nil) {
        
        self.sentenceIndex = sentence
        self.timeMarkInsideSentence = timeMarkInsideSentence
    }
}

public protocol SubtitlesIterator: TimeLineIterator {
    
    var currentTimeSlot: SubtitlesTimeSlot? { get }
    
    var currentTimeRange: Range<TimeInterval>? { get }
    
    var timeSlots: [SubtitlesTimeSlot] { get }
    
    func getNextTimeSlot() -> SubtitlesTimeSlot?
    
    func getPosition(for time: TimeInterval) -> SubtitlesTimeSlot?
}
