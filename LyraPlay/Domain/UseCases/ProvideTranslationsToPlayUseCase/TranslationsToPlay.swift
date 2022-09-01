//
//  TranslationsToPlay.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 01.09.2022.
//

import Foundation

public struct TranslationsToPlay: Equatable {

    // MARK: - Properties

    public var position: SubtitlesPosition
    public var data: TranslationsToPlayData

    // MARK: - Initializers

    public init(
        position: SubtitlesPosition,
        data: TranslationsToPlayData
    ) {

        self.position = position
        self.data = data
    }
}