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
    
    var currentTimeRange: Range<TimeInterval>? { get }
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
    
    public var currentTime: TimeInterval? { currentIteratorItem?.time }
    
    public var currentPosition: SubtitlesPosition? { currentIteratorItem?.position }
    
    public var currentTimeRange: Range<TimeInterval>? { currentIteratorItem?.timeRange }
    
    public var currentItem: SubtitlesItem? {
        
        guard let currentPosition = currentPosition else {
            return nil
        }

        return positionsIterator.getItem(position: currentPosition)
    }
    
    
    private var positionsIterator: SubtitlesPositionsIterator
    
    private var sentences: [Subtitles.Sentence] { subtitles.sentences }
    
    // MARK: - Initializers
    
    public init(subtitles: Subtitles) {
        
        self.subtitles = subtitles
        self.positionsIterator = SubtitlesPositionsIterator(subtitles: subtitles)
        self.items = Self.getItems(subtitles: subtitles)
    }
    
    // MARK: - Methods
    
    private static func getItems(subtitles: Subtitles) -> [Item] {
        
        let parser = SubtitlesTimeSlotsParser()
        let timeSlots = parser.parse(from: subtitles)
        
        var items = [Item]()

        timeSlots.forEach { slot in
            
            items.append(
                .init(
                    time: slot.timeRange.lowerBound,
                    timeRange: slot.timeRange,
                    position: slot.subtitlesPosition
                )
            )
        }
        
        if
            let lastTimeSlot = timeSlots.last,
            lastTimeSlot.timeRange.upperBound != lastTimeSlot.timeRange.lowerBound
        {
            
            items.append(.init(time: lastTimeSlot.timeRange.upperBound))
        }
        
        return items
    }

    public func move(at time: TimeInterval) -> TimeInterval? {

        let numberOfItems = items.count
        
        for index in 0..<numberOfItems {
            
            let item = items[index]
            
            if
                let timeRange = item.timeRange,
                timeRange.contains(time)
            {
                currentIndex = index
                return currentTime
            }
            
            if item.time == time {
                
                currentIndex = index
                return currentTime
            }
        }

        currentIndex = nil
        return nil
    }
    
    public func getNext() -> TimeInterval? {
        
        let nextIndex = (currentIndex ?? -1) + 1
        
        guard nextIndex < items.count else {
            return nil
        }
        
        return items[nextIndex].time
    }
    
    public func next() -> TimeInterval? {
        
        let nextIndex = (currentIndex ?? -1) + 1
        
        guard nextIndex < items.count else {
            currentIndex = nextIndex
            return nil
        }

        currentIndex = nextIndex
        return items[nextIndex].time
    }
}
