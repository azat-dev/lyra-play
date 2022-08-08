//
//  PlaySubtitlesUseCaseFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 08.08.2022.
//

import Foundation

// MARK: - Interfaces

public protocol PlaySubtitlesUseCaseFactory {

    func create() -> PlaySubtitlesUseCase
}

// MARK: - Implementations

public final class DefaultPlaySubtitlesUseCaseFactory: PlaySubtitlesUseCaseFactory {

    // MARK: - Properties

    private let subtitlesIterator: SubtitlesIterator
    private let scheduler: Scheduler

    // MARK: - Initializers

    public init(
        subtitlesIterator: SubtitlesIterator,
        scheduler: Scheduler
    ) {

        self.subtitlesIterator = subtitlesIterator
        self.scheduler = scheduler
    }

    // MARK: - Methods

    public func create() -> PlaySubtitlesUseCase {

        return DefaultPlaySubtitlesUseCase(
            subtitlesIterator: subtitlesIterator,
            scheduler: scheduler
        )
    }
}
