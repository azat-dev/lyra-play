//
//  SubtitlesPosition.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 31.08.2022.
//

import Foundation

public struct SubtitlesPosition: Equatable, Comparable, Hashable {

    // MARK: - Properties

    public var sentenceIndex: Int
    public var timeMarkIndex: Int?

    // MARK: - Initializers

    public init(
        sentenceIndex: Int,
        timeMarkIndex: Int?
    ) {

        self.sentenceIndex = sentenceIndex
        self.timeMarkIndex = timeMarkIndex
    }
    
    public static func < (lhs: SubtitlesPosition, rhs: SubtitlesPosition) -> Bool {
        
        if lhs.sentenceIndex < rhs.sentenceIndex {
            return true
        }
        
        if lhs.sentenceIndex > rhs.sentenceIndex {
            return false
        }
        
        return (lhs.timeMarkIndex ?? -1) < (rhs.timeMarkIndex ?? -1)
    }
}

extension SubtitlesPosition {
    
    public static func sentence(_ index: Int) -> Self {
        return .init(sentenceIndex: index, timeMarkIndex: nil)
    }
}
