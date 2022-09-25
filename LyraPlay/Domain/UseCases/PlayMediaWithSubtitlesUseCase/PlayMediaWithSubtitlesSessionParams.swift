//
//  PlayMediaWithSubtitlesSessionParams.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 31.08.2022.
//

import Foundation

public struct PlayMediaWithSubtitlesSessionParams: Equatable {

    // MARK: - Properties

    public var mediaId: UUID
    public var subtitlesLanguage: String

    // MARK: - Initializers

    public init(
        mediaId: UUID,
        subtitlesLanguage: String
    ) {

        self.mediaId = mediaId
        self.subtitlesLanguage = subtitlesLanguage
    }
}