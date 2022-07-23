//
//  SubtitlesIterator.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 11.07.22.
//

import Foundation

// MARK: - Interfaces

public struct SubtitlesItem {
    
    public var sentenceIndex: Subtitles.Sentence
    public var timeMarkInsideSentence: Subtitles.TimeMark?
    
    public init(sentence: Subtitles.Sentence, timeMarkInsideSentence: Subtitles.TimeMark? = nil) {
        
        self.sentenceIndex = sentence
        self.timeMarkInsideSentence = timeMarkInsideSentence
    }
}

public protocol SubtitlesIterator: TimeMarksIterator {
    
    var currentPosition: SubtitlesPosition? { get }

    var currentItem: SubtitlesItem? { get }
}

// MARK: - Implementations

public final class DefaultSubtitlesIterator: SubtitlesIterator {
    
    public var currentPosition: SubtitlesPosition?

    public var currentTime: TimeInterval? { getTime(item: currentItem) }
    
    public var currentItem: SubtitlesItem? { getItem(position: currentPosition) }
    
    private let subtitles: Subtitles
    
    private var sentences: [Subtitles.Sentence] { subtitles.sentences }
    
    private lazy var sentencesStartTimes: [TimeInterval] = {
        sentences.map { $0.startTime }
    } ()
    
    public init(subtitles: Subtitles) {
        
        self.subtitles = subtitles
    }
    
    private func getItem(position: SubtitlesPosition?) -> SubtitlesItem? {
        
        guard let position = position else {
            return nil
        }

        let sentence = sentences[position.sentenceIndex]
        
        guard
            let timeMarkIndex = position.timeMarkIndex,
            let timeMarks = sentence.timeMarks
        else {
            return .init(sentence: sentence)
        }
        
        guard timeMarkIndex < timeMarks.count else {
            return nil
        }
        
        return .init(
            sentence: sentence,
            timeMarkInsideSentence: timeMarks[timeMarkIndex]
        )
    }
    
    private func getTime(item: SubtitlesItem?) -> TimeInterval? {
        
        return item?.timeMarkInsideSentence?.startTime ?? item?.sentenceIndex.startTime
    }
    
    private func getTime(position: SubtitlesPosition?) -> TimeInterval? {
        
        return getTime(item: getItem(position: position))
    }
}

extension DefaultSubtitlesIterator {
    
    private static func searchRecentItem(items: [TimeInterval], time: TimeInterval) -> Int? {
        
        let lastIndex = items.lastIndex { $0 <= time }
        return lastIndex
    }
    
    private func searchRecentSentence(at time: TimeInterval) -> Int? {
        
        return Self.searchRecentItem(
            items: sentencesStartTimes,
            time: time
        )
    }
    
    private func searchRecentWord(at time: TimeInterval, in sentenceIndex: Int) -> Int? {
        
        if sentenceIndex >= sentences.count {
            return nil
        }
        
        let sentence = sentences[sentenceIndex]
        
        return sentence.timeMarks?.lastIndex { timeMark in
            
            guard timeMark.startTime <= time else {
                return false
            }
            
            if let duration = timeMark.duration {
                
                return time < (timeMark.startTime + duration)
            }
            
            return true
        }
    }
    
    public func move(at time: TimeInterval) -> TimeInterval? {
        
        guard
            let recentSentence = searchRecentSentence(at: time)
        else {
            currentPosition = nil
            return currentTime
        }
        
        let recentWord = searchRecentWord(at: time, in: recentSentence)
        currentPosition = .init(
            sentence: recentSentence,
            timeMarkIndex: recentWord
        )
        
        return currentTime
    }
    
    public func getNextPosition() -> SubtitlesPosition? {
        
        guard let currentPosition = currentPosition else {
        
            if let firstSentence = sentences.first {
                
                guard
                    let timeMarks = firstSentence.timeMarks,
                    let firstTimeMark = timeMarks.first,
                    firstTimeMark.startTime == firstSentence.startTime
                else {
                    return .init(sentence: 0, timeMarkIndex: nil)
                }

                return .init(sentence: 0, timeMarkIndex: 0)
            }
            
            return nil
        }
        
        let sentence = sentences[currentPosition.sentenceIndex]
        
        if
            let timeMarks = sentence.timeMarks,
            !timeMarks.isEmpty
        {
            
            guard let currentWordIndex = currentPosition.timeMarkIndex else {

                return .init(
                    sentence: currentPosition.sentenceIndex,
                    timeMarkIndex: 0
                )
            }
            
            let nextTimeMarkIndex = currentWordIndex + 1
            if nextTimeMarkIndex < timeMarks.count {
                return .init(
                    sentence: currentPosition.sentenceIndex,
                    timeMarkIndex: nextTimeMarkIndex
                )
            }
        }
        
        let nextSentenceIndex = currentPosition.sentenceIndex + 1
        
        guard nextSentenceIndex < sentences.count else {
            return nil
        }

        let nextSentence = sentences[nextSentenceIndex]
        
        guard
            let firstTimeMarkOfNextSentence = nextSentence.timeMarks?.first
        else {
            return .init(
                sentence: nextSentenceIndex,
                timeMarkIndex: nil
            )
        }
        
        return .init(
            sentence: nextSentenceIndex,
            timeMarkIndex: firstTimeMarkOfNextSentence.startTime == nextSentence.startTime ? 0 : nil
        )
    }
    
    public func getNext() -> TimeInterval? {
        
        let nextPosition = getNextPosition()
        return getTime(position: nextPosition)
    }
    
    public func next() -> TimeInterval? {
        
        let nextPosition = getNextPosition()
        currentPosition = nextPosition
        
        return currentTime
    }
}
