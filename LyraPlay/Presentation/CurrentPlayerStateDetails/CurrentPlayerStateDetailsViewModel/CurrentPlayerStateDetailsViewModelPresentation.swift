//
//  CurrentPlayerStateDetailsViewModelPresentation.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 30.09.2022.
//

import Foundation

public struct CurrentPlayerStateDetailsViewModelPresentation {

    // MARK: - Properties

    public let mediaId: UUID
    public var title: String
    public var subtitle: String
    public var coverImage: Data?
    public var isPlaying: Bool
    public var subtitlesPresenterViewModel: SubtitlesPresenterViewModel?

    // MARK: - Initializers

    public init(
        mediaId: UUID,
        title: String,
        subtitle: String,
        coverImage: Data?,
        isPlaying: Bool,
        subtitlesPresenterViewModel: SubtitlesPresenterViewModel?
    ) {

        self.mediaId = mediaId
        self.title = title
        self.subtitle = subtitle
        self.coverImage = coverImage
        self.isPlaying = isPlaying
        self.subtitlesPresenterViewModel = subtitlesPresenterViewModel
    }
}
