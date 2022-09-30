//
//  CurrentPlayerStateDetailsViewModelPresentation.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 30.09.2022.
//

import Foundation

public struct CurrentPlayerStateDetailsViewModelPresentation: Equatable {

    // MARK: - Properties

    public var title: String
    public var subtitle: String
    public var coverImage: Data?
    public var isPlaying: Bool

    // MARK: - Initializers

    public init(
        title: String,
        subtitle: String,
        coverImage: Data?,
        isPlaying: Bool
    ) {

        self.title = title
        self.subtitle = subtitle
        self.coverImage = coverImage
        self.isPlaying = isPlaying
    }
}
