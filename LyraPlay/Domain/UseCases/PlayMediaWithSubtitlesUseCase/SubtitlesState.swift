//
//  SubtitlesState.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 31.08.2022.
//

import Foundation

public struct SubtitlesState: Equatable {

    // MARK: - Properties

    public let timeSlot: SubtitlesTimeSlot?
    public let subtitles: Subtitles
    public let timeSlots: [SubtitlesTimeSlot]

    // MARK: - Initializers

    public init(
        timeSlot: SubtitlesTimeSlot?,
        subtitles: Subtitles,
        timeSlots: [SubtitlesTimeSlot]
    ) {

        self.timeSlot = timeSlot
        self.subtitles = subtitles
        self.timeSlots = timeSlots
    }
    
    public func positioned(_ timeSlot: SubtitlesTimeSlot?) -> SubtitlesState {
        
        return SubtitlesState(
            timeSlot: timeSlot,
            subtitles: subtitles,
            timeSlots: timeSlots
        )
    }
}
