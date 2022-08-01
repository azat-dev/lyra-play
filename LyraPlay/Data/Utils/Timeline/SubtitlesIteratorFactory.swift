//
//  SubtitlesIteratorFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 01.08.22.
//

import Foundation

// MARK: - Interfaces

public protocol SubtitlesIteratorFactory {
    
    func create(for subtitles: Subtitles) -> TimeMarksIterator
}

// MARK: - Implementations

public final class DefaultSubtitlesIteratorFactory: SubtitlesIteratorFactory {
    
    public func create(for subtitles: Subtitles) -> SubtitlesIterator {
        
        return DefaultSubtitlesIterator(subtitles: subtitles)
    }
}
