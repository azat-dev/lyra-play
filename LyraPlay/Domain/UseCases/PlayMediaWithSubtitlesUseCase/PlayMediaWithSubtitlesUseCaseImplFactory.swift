//
//  PlayMediaWithSubtitlesUseCaseImplFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 31.08.2022.
//

import Foundation

public final class PlayMediaWithSubtitlesUseCaseImplFactory: PlayMediaWithSubtitlesUseCaseFactory {

    // MARK: - Properties

    private let playMediaUseCase: PlayMediaUseCase
    private let playSubtitlesUseCaseFactory: PlaySubtitlesUseCaseFactory
    private let loadSubtitlesUseCaseFactory: LoadSubtitlesUseCaseFactory

    // MARK: - Initializers

    public init(
        playMediaUseCase: PlayMediaUseCase,
        playSubtitlesUseCaseFactory: PlaySubtitlesUseCaseFactory,
        loadSubtitlesUseCaseFactory: LoadSubtitlesUseCaseFactory
    ) {

        self.playMediaUseCase = playMediaUseCase
        self.playSubtitlesUseCaseFactory = playSubtitlesUseCaseFactory
        self.loadSubtitlesUseCaseFactory = loadSubtitlesUseCaseFactory
    }

    // MARK: - Methods

    public func create() -> PlayMediaWithSubtitlesUseCase {
        
        let loadSubtitlesUseCase = loadSubtitlesUseCaseFactory.create()

        return PlayMediaWithSubtitlesUseCaseImpl(
            playMediaUseCase: playMediaUseCase,
            playSubtitlesUseCaseFactory: playSubtitlesUseCaseFactory,
            loadSubtitlesUseCase: loadSubtitlesUseCase
        )
    }

}
