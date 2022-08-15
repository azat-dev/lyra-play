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

public protocol SubtitlesIterator: TimeLineIterator {
    
    var currentPosition: SubtitlesPosition? { get }

    var currentItem: SubtitlesItem? { get }
    
    var currentTimeRange: Range<TimeInterval>? { get }
    
    func getNextPosition() -> SubtitlesPosition?
}

// MARK: - Implementations

public final class DefaultSubtitlesIterator: SubtitlesIterator {
    
    private struct Item {
    
        var time: TimeInterval
        var timeRange: Range<TimeInterval>? = nil
        var position: SubtitlesPosition? = nil
    }

    
    // MARK: - Properties
    
    private let subtitles: Subtitles

    private let subtitlesTimeSlots: [SubtitlesTimeSlot]
    
    private var currentIndex: Int? = nil

    private var items: [Item]
    
    private var currentIteratorItem: Item? {
        
        guard let currentIndex = currentIndex else {
            return nil
        }
        
        if currentIndex >=  items.count {
            return nil
        }

        return items[currentIndex]
    }
    
    public var lastEventTime: TimeInterval? { currentIteratorItem?.time }
    
    public var currentPosition: SubtitlesPosition? { currentIteratorItem?.position }
    
    public var currentTimeRange: Range<TimeInterval>? { currentIteratorItem?.timeRange }
    
    public var currentItem: SubtitlesItem? {
        
        guard let currentPosition = currentPosition else {
            return nil
        }

        let sentence = subtitles.sentences[currentPosition.sentenceIndex]
        
        guard
            let timeMarkIndex = currentPosition.timeMarkIndex,
            let timeMarks = sentence.timeMarks
        else {
            return .init(sentence: sentence)
        }
        
        return .init(
            sentence: sentence,
            timeMarkInsideSentence: timeMarks[timeMarkIndex]
        )
    }
    
    
    private var sentences: [Subtitles.Sentence] { subtitles.sentences }
    
    // MARK: - Initializers
    
    public init(subtitles: Subtitles, subtitlesTimeSlots: [SubtitlesTimeSlot]) {
        
        self.subtitles = subtitles
        self.subtitlesTimeSlots = subtitlesTimeSlots
        
        self.items = Self.getItems(subtitles: subtitles, subtitlesTimeSlots: subtitlesTimeSlots)
    }
    
    // MARK: - Methods
    
    private static func getItems(subtitles: Subtitles, subtitlesTimeSlots: [SubtitlesTimeSlot]) -> [Item] {
        
        var items = [Item]()

        for timeSlot in subtitlesTimeSlots {
            
            items.append(
                .init(
                    time: timeSlot.timeRange.lowerBound,
                    timeRange: timeSlot.timeRange,
                    position: timeSlot.subtitlesPosition
                )
            )
        }
        
        if
            let lastTimeSlot = subtitlesTimeSlots.last,
            lastTimeSlot.timeRange.upperBound != lastTimeSlot.timeRange.lowerBound
        {
            
            items.append(.init(time: lastTimeSlot.timeRange.upperBound))
        }
        
        return items
    }

    public func beginNextExecution(from time: TimeInterval) -> TimeInterval? {

        let numberOfItems = items.count
        
        if let lastItem = items.last,
           lastItem.time < time {
            
            currentIndex = items.count - 1
            return lastItem.time
        }
        
        for index in 0..<numberOfItems {
            
            let item = items[index]
            
            if
                let timeRange = item.timeRange,
                timeRange.contains(time)
            {
                currentIndex = index
                return lastEventTime
            }
            
            if item.time == time {
                
                currentIndex = index
                return lastEventTime
            }
        }

        currentIndex = nil
        return nil
    }
    
    public func getTimeOfNextEvent() -> TimeInterval? {
        
        let nextIndex = (currentIndex ?? -1) + 1
        
        guard nextIndex < items.count else {
            return nil
        }
        
        return items[nextIndex].time
    }
    
    public func getNextPosition() -> SubtitlesPosition? {
        
        let nextIndex = (currentIndex ?? -1) + 1
        
        guard nextIndex < items.count else {
            return nil
        }
        
        return items[nextIndex].position
    }
    
    public func moveToNextEvent() -> TimeInterval? {
        
        let nextIndex = (currentIndex ?? -1) + 1
        
        guard nextIndex < items.count else {
            currentIndex = nextIndex
            return nil
        }

        currentIndex = nextIndex
        return items[nextIndex].time
    }
}
