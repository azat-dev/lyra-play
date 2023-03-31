//
//  AdvancedPlayerSession.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 06.08.2022.
//

import Foundation

public struct AdvancedPlayerSession: Equatable {

    public let mediaId: UUID
    public let nativeLanguage: String
    public let learningLanguage: String
    public let subtitles: Subtitles
    public let timeSlots: [SubtitlesTimeSlot]

    public init(
        mediaId: UUID,
        nativeLanguage: String,
        learningLanguage: String,
        subtitles: Subtitles,
        timeSlots: [SubtitlesTimeSlot]
    ) {

        self.mediaId = mediaId
        self.nativeLanguage = nativeLanguage
        self.learningLanguage = learningLanguage
        self.subtitles = subtitles
        self.timeSlots = timeSlots
    }
}
