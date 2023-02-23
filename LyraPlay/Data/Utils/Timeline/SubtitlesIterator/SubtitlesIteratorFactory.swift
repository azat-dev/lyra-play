//
//  SubtitlesIteratorFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 01.08.22.
//

import Foundation

// MARK: - Interfaces

public protocol SubtitlesIteratorFactory {
    
    func make(for subtitles: Subtitles) -> SubtitlesIterator
}
