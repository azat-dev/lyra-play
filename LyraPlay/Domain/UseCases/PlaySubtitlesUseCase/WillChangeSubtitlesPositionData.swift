//
//  WillChangeSubtitlesPositionData.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 31.08.2022.
//

import Foundation

public struct WillChangeSubtitlesPositionData: Equatable {

    // MARK: - Properties

    public var from: SubtitlesPosition?
    public var to: SubtitlesPosition?

    // MARK: - Initializers

    public init(
        from: SubtitlesPosition?,
        to: SubtitlesPosition?
    ) {

        self.from = from
        self.to = to
    }
}