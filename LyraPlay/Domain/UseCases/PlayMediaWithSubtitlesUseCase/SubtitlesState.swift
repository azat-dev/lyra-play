//
//  SubtitlesState.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 31.08.2022.
//

import Foundation

public struct SubtitlesState: Equatable {

    // MARK: - Properties

    public var position: SubtitlesPosition?
    public var subtitles: Subtitles

    // MARK: - Initializers

    public init(
        position: SubtitlesPosition?,
        subtitles: Subtitles
    ) {

        self.position = position
        self.subtitles = subtitles
    }
    
    public func positioned(_ position: SubtitlesPosition) -> SubtitlesState {
        
        var newState = self
        newState.position = position
        return newState
    }
}
