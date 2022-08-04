//
//  SubtitlesTimeSlotsParser.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 04.08.22.
//

import Foundation

public struct SubtitlesTimeSlot: Equatable {
    
    public var timeRange: Range<TimeInterval>
    public var subtitlesPosition: SubtitlesPosition?
    
    public init(timeRange: Range<TimeInterval>, subtitlesPosition: SubtitlesPosition? = nil) {
        
        self.timeRange = timeRange
        self.subtitlesPosition = subtitlesPosition
    }
}

public class SubtitlesTimeSlotsParser {
    
    public init() {}
    
    private func getSentenceEndTime(subtitles: Subtitles, sentenceIndex: Int) -> TimeInterval {
        
        let sentences = subtitles.sentences
        let sentence = sentences[sentenceIndex]
        
        if let duration = sentence.duration {
            
            return sentence.startTime + duration
        }
        
        let nextSentenceIndex = sentenceIndex + 1
        
        guard nextSentenceIndex < sentences.count else {
            return subtitles.duration
        }
        
        let nextSentence = sentences[nextSentenceIndex]
        
        return nextSentence.startTime
    }
    
    private func getTimeMarkEndTime(subtitles: Subtitles, sentenceIndex: Int, timeMarkIndex: Int) -> TimeInterval {
        
        let sentences = subtitles.sentences
        let sentence = sentences[sentenceIndex]
        
        let timeMarks = sentence.timeMarks ?? []
        let timeMark = timeMarks[timeMarkIndex]
        
        if let duration = timeMark.duration  {

            return timeMark.startTime + duration
        }

        let nextTimeMarkIndex = timeMarkIndex + 1
        
        if nextTimeMarkIndex < timeMarks.count {
            
            let nextTimeMark = timeMarks[nextTimeMarkIndex]
            return nextTimeMark.startTime
        }
        
        return getSentenceEndTime(subtitles: subtitles, sentenceIndex: sentenceIndex)
    }
    
    public func parse(from subtitles: Subtitles) -> [SubtitlesTimeSlot] {

        var timeSlots = [SubtitlesTimeSlot]()
        
        let sentences = subtitles.sentences
        let numberOfSentences = sentences.count
        
        var lastEndTime: TimeInterval = 0
        
        let appendSentenceSlot = { (sentenceIndex: Int, range: Range<TimeInterval>) -> Void in
            
            let sentenceSlot = SubtitlesTimeSlot(
                timeRange: range,
                subtitlesPosition: .init(sentenceIndex: sentenceIndex, timeMarkIndex: nil)
            )
            
            timeSlots.append(sentenceSlot)
        }
        
        for sentenceIndex in 0..<numberOfSentences {

            let sentence = sentences[sentenceIndex]
            let startTime = sentence.startTime
            
            if lastEndTime < startTime {
            
                let emptySlot = SubtitlesTimeSlot(
                    timeRange: (lastEndTime..<startTime),
                    subtitlesPosition: nil
                )
                
                timeSlots.append(emptySlot)
                lastEndTime = startTime
            }
            
            let sentenceEndTime = getSentenceEndTime(subtitles: subtitles, sentenceIndex: sentenceIndex)
            appendSentenceSlot(sentenceIndex, (startTime..<sentenceEndTime))
            lastEndTime = sentenceEndTime
            
            let timeMarks = sentence.timeMarks ?? []
            let numberOfTimeMarks = timeMarks.count
            
            for timeMarkIndex in 0..<numberOfTimeMarks {
                
                let timeMark = timeMarks[timeMarkIndex]
                let timeMarkStartTime = timeMark.startTime
                
                let timeMarkEndTime = getTimeMarkEndTime(subtitles: subtitles, sentenceIndex: sentenceIndex, timeMarkIndex: timeMarkIndex)

                if timeMarkIndex == 0 {
                    
                    timeSlots.removeLast()
                    
                    if startTime != timeMarkStartTime {
                        
                        appendSentenceSlot(sentenceIndex, (startTime..<timeMarkStartTime))
                        lastEndTime = timeMarkStartTime
                    }
                }
                
                if lastEndTime < timeMarkStartTime {
                    
                    appendSentenceSlot(sentenceIndex, (lastEndTime..<timeMarkStartTime))
                    lastEndTime = timeMarkStartTime
                }

                let timeMarkSlot = SubtitlesTimeSlot(
                    timeRange: (timeMarkStartTime..<timeMarkEndTime),
                    subtitlesPosition: .init(
                        sentenceIndex: sentenceIndex,
                        timeMarkIndex: timeMarkIndex
                    )
                )
                
                timeSlots.append(timeMarkSlot)
                lastEndTime = timeMarkEndTime
            }
            
            if lastEndTime < sentenceEndTime {
                
                appendSentenceSlot(sentenceIndex, (lastEndTime..<sentenceEndTime))
                lastEndTime = sentenceEndTime
            }
        }
        
        let lastSlot = timeSlots.last
        
        if lastSlot == nil || lastSlot!.timeRange.upperBound < subtitles.duration {
            
            let emptySlot = SubtitlesTimeSlot(timeRange: lastEndTime..<subtitles.duration)
            timeSlots.append(emptySlot)
        }
        
        return timeSlots
    }
}
