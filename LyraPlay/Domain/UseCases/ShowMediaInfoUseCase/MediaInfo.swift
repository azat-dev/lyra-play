//
//  MediaInfo.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 01.09.2022.
//

import Foundation

public struct MediaInfo: Equatable {

    // MARK: - Properties

    public let id: UUID
    public let coverImage: Data
    public let title: String
    public let artist: String?
    public let duration: Double

    // MARK: - Initializers

    public init(
        id: UUID,
        coverImage: Data,
        title: String,
        artist: String?,
        duration: Double
    ) {

        self.id = id
        self.coverImage = coverImage
        self.title = title
        self.artist = artist
        self.duration = duration
    }
}
