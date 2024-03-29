//
//  SubtitlesIteratorImpl.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 22.02.23.
//

import Foundation

public final class SubtitlesIteratorImpl: SubtitlesIterator {
    
    // MARK: - Properties

    public var currentTimeSlot: SubtitlesTimeSlot? {
        
        guard
            let currentTimeSlotIndex = currentTimeSlotIndex,
            currentTimeSlotIndex < timeSlots.count
        else {
            return nil
        }
        
        return timeSlots[currentTimeSlotIndex]
    }
    
    public let timeSlots: [SubtitlesTimeSlot]
    
    private lazy var lastItem: SubtitlesTimeSlot = {
        return .init(
            index: timeSlots.count,
            timeRange: endTime..<endTime
        )
    }()
    
    private var currentIteratorItem: SubtitlesTimeSlot? {
        
        guard let timeSlotIndex = currentTimeSlotIndex else {
            return nil
        }
        
        guard timeSlotIndex < timeSlots.count else {
            return nil
        }

        return timeSlots[timeSlotIndex]
    }
    
    private lazy var endTime: TimeInterval = {
        
        guard let lastSlot = timeSlots.last else {
            return 0
        }
        
        return lastSlot.timeRange.upperBound
    } ()
    
    public var lastEventTime: TimeInterval? { currentIteratorItem?.timeRange.lowerBound }
    
    public var currentPosition: SubtitlesPosition? { currentIteratorItem?.subtitlesPosition }
    
    public var currentTimeRange: Range<TimeInterval>? { currentIteratorItem?.timeRange }
    
    public var currentTimeSlotIndex: Int?
    
    
    // MARK: - Initializers
    
    public init(subtitlesTimeSlots: [SubtitlesTimeSlot]) {
        
        self.timeSlots = subtitlesTimeSlots
    }
    
    // MARK: - Methods
    
    public func getPosition(for time: TimeInterval) -> SubtitlesTimeSlot? {
        
        let foundIndex = timeSlots.binarySearch(
            range: 0..<timeSlots.count,
            comparator: { value in
                
                if
                    value.timeRange.contains(time) ||
                    value.timeRange.lowerBound == time && value.timeRange.upperBound == time
                {
                    return .orderedSame
                }
                
                if time < value.timeRange.lowerBound {
                    return .orderedAscending
                }
                
                return .orderedDescending
            }
        )
        
        guard let foundIndex = foundIndex else {
            return nil
        }

        return timeSlots[foundIndex]
    }
    
    public func beginNextExecution(from time: TimeInterval) -> TimeInterval? {
        
        let subtitlesEndTime = self.endTime
        
        if time >= subtitlesEndTime {
            
            currentTimeSlotIndex = timeSlots.count
            return lastEventTime
        }
        
        let numberOfItems = timeSlots.count
        
        for index in 0..<numberOfItems {
            
            let item = timeSlots[index]
            
            if item.timeRange.lowerBound >= time {
                
                if index == 0 {
                    currentTimeSlotIndex = nil
                    return nil
                }
                
                currentTimeSlotIndex = index - 1
                return lastEventTime
            }
        }
        
        currentTimeSlotIndex = timeSlots.count
        return lastEventTime
    }
    
    private func getNextIndex() -> Int? {
        
        guard let timeSlotIndex = currentTimeSlotIndex else {
            return 0
        }
        
        let nextIndex = timeSlotIndex + 1

        if nextIndex >= timeSlots.count {
            return nil
        }

        return nextIndex
    }
    
    public func getTimeOfNextEvent() -> TimeInterval? {
        
        guard let nextIndex = getNextIndex() else {
            return nil
        }
        
        guard nextIndex < timeSlots.count else {
            return nil
        }

        return timeSlots[nextIndex].timeRange.lowerBound
    }
    
    public func getNextTimeSlot() -> SubtitlesTimeSlot? {
        
        guard let nextIndex = getNextIndex() else {
            return nil
        }

        if nextIndex == timeSlots.count {
            return nil
        }
        
        return timeSlots[nextIndex]
    }
    
    public func moveToNextEvent() -> TimeInterval? {

        guard let nextIndex = getNextIndex() else {
            return nil
        }

        if nextIndex == timeSlots.count {
            currentTimeSlotIndex = nextIndex
            return nil
        }
        
        currentTimeSlotIndex = nextIndex
        return lastEventTime
    }
}
