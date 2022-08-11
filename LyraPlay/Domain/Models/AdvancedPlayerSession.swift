//
//  AdvancedPlayerSession.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 06.08.2022.
//

import Foundation

public struct AdvancedPlayerSession: Equatable {

    public var mediaId: UUID
    public var nativeLanguage: String
    public var learningLanguage: String
    public var subtitles: Subtitles

    public init(
        mediaId: UUID,
        nativeLanguage: String,
        learningLanguage: String,
        subtitles: Subtitles
    ) {

        self.mediaId = mediaId
        self.nativeLanguage = nativeLanguage
        self.learningLanguage = learningLanguage
        self.subtitles = subtitles
    }
}
