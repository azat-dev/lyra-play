//
//  PlaySubtitlesUseCaseImplFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 31.08.2022.
//

import Foundation

public final class PlaySubtitlesUseCaseImplFactory: PlaySubtitlesUseCaseFactory {

    // MARK: - Properties

    private let subtitlesIteratorFactory: SubtitlesIteratorFactory
    private let schedulerFactory: SchedulerFactory

    // MARK: - Initializers

    public init(
        subtitlesIteratorFactory: SubtitlesIteratorFactory,
        schedulerFactory: SchedulerFactory
    ) {

        self.subtitlesIteratorFactory = subtitlesIteratorFactory
        self.schedulerFactory = schedulerFactory
    }

    // MARK: - Methods

    public func make(subtitles: Subtitles) -> PlaySubtitlesUseCase {

        let subtitlesIterator = subtitlesIteratorFactory.make(for: subtitles)
        let scheduler = schedulerFactory.make()

        return PlaySubtitlesUseCaseImpl(
            subtitlesIterator: subtitlesIterator,
            scheduler: scheduler
        )
    }

}
