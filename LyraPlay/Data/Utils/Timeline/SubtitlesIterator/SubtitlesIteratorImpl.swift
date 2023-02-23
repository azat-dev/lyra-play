//
//  SubtitlesIteratorImpl.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 22.02.23.
//

import Foundation

public final class SubtitlesIteratorImpl: SubtitlesIterator {
    
    // MARK: - Properties
    
    private let subtitlesTimeSlots: [SubtitlesTimeSlot]
    
    private var currentIndex = -1
    
    private lazy var endIndex: Int = {
        subtitlesTimeSlots.count
    }()
    
    private lazy var lastItem: SubtitlesTimeSlot = {
        return .init(timeRange: endTime..<endTime)
    }()
    
    private var currentIteratorItem: SubtitlesTimeSlot? {

        if currentIndex < 0 || currentIndex > endIndex {
            return nil
        }
        
        if currentIndex == endIndex {
            return lastItem
        }
        
        return subtitlesTimeSlots[currentIndex]
    }
    
    private lazy var endTime: TimeInterval = {
        
        guard let lastSlot = subtitlesTimeSlots.last else {
            return 0
        }
        
        return lastSlot.timeRange.upperBound
    } ()
    
    public var lastEventTime: TimeInterval? { currentIteratorItem?.timeRange.lowerBound }
    
    public var currentPosition: SubtitlesPosition? { currentIteratorItem?.subtitlesPosition }
    
    public var currentTimeRange: Range<TimeInterval>? { currentIteratorItem?.timeRange }
    
    
    // MARK: - Initializers
    
    public init(subtitlesTimeSlots: [SubtitlesTimeSlot]) {
        
        self.subtitlesTimeSlots = subtitlesTimeSlots
    }
    
    // MARK: - Methods
    
    public func beginNextExecution(from time: TimeInterval) -> TimeInterval? {
        
        let subtitlesEndTime = self.endTime
        
        if time >= subtitlesEndTime {
            
            currentIndex = endIndex - 1
            return lastEventTime
        }
        
        let numberOfItems = subtitlesTimeSlots.count
        
        for index in 0..<numberOfItems {
            
            let item = subtitlesTimeSlots[index]
            
            if item.timeRange.lowerBound >= time {
                
                if index == 0 {
                    return nil
                }
                
                currentIndex = index - 1
                return lastEventTime
            }
        }
        
        currentIndex = endIndex - 1
        return lastEventTime
    }
    
    private func getNextIndex() -> Int? {
        
        let nextIndex = currentIndex + 1

        if nextIndex > endIndex {
            return nil
        }

        if nextIndex == endIndex {
            return nextIndex
        }
        
        return nextIndex
    }
    
    public func getTimeOfNextEvent() -> TimeInterval? {
        
        guard let nextIndex = getNextIndex() else {
            return nil
        }

        if nextIndex == endIndex {
            return endTime
        }

        return subtitlesTimeSlots[nextIndex].timeRange.lowerBound
    }
    
    public func getNextPosition() -> SubtitlesPosition? {
        
        guard let nextIndex = getNextIndex() else {
            return nil
        }

        if nextIndex == endIndex {
            return nil
        }
        
        return subtitlesTimeSlots[nextIndex].subtitlesPosition
    }
    
    public func moveToNextEvent() -> TimeInterval? {

        guard let nextIndex = getNextIndex() else {
            return nil
        }

        if nextIndex == endIndex {
            currentIndex = nextIndex
            return nil
        }
        
        currentIndex = nextIndex
        return lastEventTime
    }
}
