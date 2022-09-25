//
//  SubtitlesIteratorFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 01.08.22.
//

import Foundation

// MARK: - Interfaces

public protocol SubtitlesIteratorFactory {
    
    func create(for subtitles: Subtitles) -> SubtitlesIterator
}

// MARK: - Implementations

public final class SubtitlesIteratorFactoryImpl: SubtitlesIteratorFactory {
    
    public init() {}
    
    public func create(for subtitles: Subtitles) -> SubtitlesIterator {
        
        let timeSlotsParser = SubtitlesTimeSlotsParser()
        
        return SubtitlesIteratorImpl(
            subtitlesTimeSlots: timeSlotsParser.parse(from: subtitles)
        )
    }
}
