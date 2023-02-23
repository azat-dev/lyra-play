//
//  SubtitlesIteratorFactoryImpl.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 23.02.23.
//

import Foundation

public final class SubtitlesIteratorFactoryImpl: SubtitlesIteratorFactory {
    
    // MARK: - Initializers
    
    public init() {}
    
    // MARK: - Methods
    
    public func make(for subtitles: Subtitles) -> SubtitlesIterator {
        
        let timeSlotsParser = SubtitlesTimeSlotsParser()
        
        return SubtitlesIteratorImpl(subtitlesTimeSlots: timeSlotsParser.parse(from: subtitles))
    }
}
