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
    private let schedulerFactory: TimelineSchedulerFactory

    // MARK: - Initializers

    public init(
        subtitlesIteratorFactory: SubtitlesIteratorFactory,
        schedulerFactory: TimelineSchedulerFactory
    ) {

        self.subtitlesIteratorFactory = subtitlesIteratorFactory
        self.schedulerFactory = schedulerFactory
    }

    // MARK: - Methods

    public func make(
        subtitles: Subtitles,
        delegate: PlaySubtitlesUseCaseDelegate?
    ) -> PlaySubtitlesUseCase {

        let subtitlesIterator = subtitlesIteratorFactory.make(for: subtitles)

        return PlaySubtitlesUseCaseImpl(
            subtitlesIterator: subtitlesIterator,
            schedulerFactory: schedulerFactory,
            delegate: delegate
        )
    }
}
