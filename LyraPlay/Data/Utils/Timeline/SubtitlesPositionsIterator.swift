//
//  SubtitlesPositionsIteratorTests.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 04.08.22.
//

import Foundation

public class SubtitlesPositionsIterator {
    
    private let subtitles: Subtitles
    
    public init(subtitles: Subtitles) {
        
        self.subtitles = subtitles
    }
    
    public func getItem(position: SubtitlesPosition) -> SubtitlesItem {
        
        let sentences = subtitles.sentences
        let sentence = sentences[position.sentenceIndex]
        var timeMark: Subtitles.TimeMark? = nil
        
        if
            let timeMarks = sentence.timeMarks,
            let timeMarkIndex = position.timeMarkIndex
        {
            
            timeMark = timeMarks[timeMarkIndex]
        }
        
        return .init(
            sentence: sentence,
            timeMarkInsideSentence: timeMark
        )
    }
    
    public func next(from position : SubtitlesPosition?) -> SubtitlesPosition? {
        
        let sentences = subtitles.sentences
        
        guard let position = position else {
            
            guard let firstSentence = sentences.first else {
                return nil
            }
            
            if
                let firstTimeMark = firstSentence.timeMarks?.first,
                firstTimeMark.startTime == firstSentence.startTime
            {
                
                return .init(
                    sentenceIndex: 0,
                    timeMarkIndex: 0
                )
            }
            
            return .init(
                sentenceIndex: 0,
                timeMarkIndex: nil
            )
        }
        
        let sentence = sentences[position.sentenceIndex]
        let timeMarks = sentence.timeMarks ?? []
        
        let nextSentenceIndex = position.sentenceIndex + 1
        
        if position.timeMarkIndex == nil && !timeMarks.isEmpty {
            return .init(
                sentenceIndex: position.sentenceIndex,
                timeMarkIndex: 0
            )
        }
        
        if let timeMarkIndex = position.timeMarkIndex,
            (timeMarkIndex + 1) < timeMarks.count {
            
            return .init(
                sentenceIndex: position.sentenceIndex,
                timeMarkIndex: timeMarkIndex + 1
            )
        }
        
        guard nextSentenceIndex < sentences.count else {
            
            return nil
        }
        
        let nextSentence = sentences[nextSentenceIndex]
        
        if
            let firstTimeMark = nextSentence.timeMarks?.first,
            firstTimeMark.startTime == nextSentence.startTime
        {
            
            return .init(
                sentenceIndex: nextSentenceIndex,
                timeMarkIndex: 0
            )
        }
        
        return .init(
            sentenceIndex: nextSentenceIndex,
            timeMarkIndex: nil
        )
    }
}
