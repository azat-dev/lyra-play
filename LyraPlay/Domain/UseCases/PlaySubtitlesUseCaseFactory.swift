//
//  PlaySubtitlesUseCaseFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 08.08.2022.
//

import Foundation

// MARK: - Interfaces

public protocol PlaySubtitlesUseCaseFactory {

    func create(with: Subtitles) -> PlaySubtitlesUseCase
}

// MARK: - Implementations

public final class DefaultPlaySubtitlesUseCaseFactory: PlaySubtitlesUseCaseFactory {

    // MARK: - Properties

    private let subtitlesIteratorFactory: SubtitlesIteratorFactory
    private let scheduler: Scheduler

    // MARK: - Initializers

    public init(
        subtitlesIteratorFactory: SubtitlesIteratorFactory,
        scheduler: Scheduler
    ) {

        self.subtitlesIteratorFactory = subtitlesIteratorFactory
        self.scheduler = scheduler
    }

    // MARK: - Methods

    public func create(with subtitles: Subtitles) -> PlaySubtitlesUseCase {

        return DefaultPlaySubtitlesUseCase(
            subtitlesIterator: subtitlesIteratorFactory.create(for: subtitles),
            scheduler: scheduler
        )
    }
}
