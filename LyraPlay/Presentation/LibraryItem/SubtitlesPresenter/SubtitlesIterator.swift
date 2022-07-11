//
//  SubtitlesIterator.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 11.07.22.
//

import Foundation

// MARK: - Interfaces

public protocol SubtitlesIterator {
    
    var isLast: Bool { get }
}

// MARK: - Implementations

public final class DefaultSubtitlesIterator: SubtitlesIterator {

    private var subtitles: Subtitles
    private var currentSentenceIndex = 0
    private var currentSentenceItemIndex = 0
    
    public init(subtitles: Subtitles) {
        
        self.subtitles = subtitles
    }
    
    public var isLast: Bool {
        
        let nextSentenceIndex = currentSentenceIndex + 1
        return nextSentenceIndex >= subtitles.sentences.count
    }
}

