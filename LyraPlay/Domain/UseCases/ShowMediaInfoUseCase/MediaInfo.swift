//
//  MediaInfo.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 01.09.2022.
//

import Foundation

public struct MediaInfo: Equatable {

    // MARK: - Properties

    public var id: String
    public var coverImage: Data
    public var title: String
    public var artist: String?
    public var duration: Double

    // MARK: - Initializers

    public init(
        id: String,
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
