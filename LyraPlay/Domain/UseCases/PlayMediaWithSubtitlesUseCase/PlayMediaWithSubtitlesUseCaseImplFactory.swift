//
//  PlayMediaWithSubtitlesUseCaseImplFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 31.08.2022.
//

import Foundation

public final class PlayMediaWithSubtitlesUseCaseImplFactory: PlayMediaWithSubtitlesUseCaseFactory {

    // MARK: - Properties

    private let playMediaUseCaseFactory: PlayMediaUseCaseFactory
    private let playSubtitlesUseCaseFactory: PlaySubtitlesUseCaseFactory
    private let loadSubtitlesUseCaseFactory: LoadSubtitlesUseCaseFactory

    // MARK: - Initializers

    public init(
        playMediaUseCaseFactory: PlayMediaUseCaseFactory,
        playSubtitlesUseCaseFactory: PlaySubtitlesUseCaseFactory,
        loadSubtitlesUseCaseFactory: LoadSubtitlesUseCaseFactory
    ) {

        self.playMediaUseCaseFactory = playMediaUseCaseFactory
        self.playSubtitlesUseCaseFactory = playSubtitlesUseCaseFactory
        self.loadSubtitlesUseCaseFactory = loadSubtitlesUseCaseFactory
    }

    // MARK: - Methods

    public func make() -> PlayMediaWithSubtitlesUseCase {
        
        let playMediaUseCase = playMediaUseCaseFactory.make()
        let loadSubtitlesUseCase = loadSubtitlesUseCaseFactory.make()

        return PlayMediaWithSubtitlesUseCaseImpl(
            playMediaUseCase: playMediaUseCase,
            playSubtitlesUseCaseFactory: playSubtitlesUseCaseFactory,
            loadSubtitlesUseCase: loadSubtitlesUseCase
        )
    }

}
