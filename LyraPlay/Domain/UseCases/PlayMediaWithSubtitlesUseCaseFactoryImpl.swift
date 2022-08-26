//
//  PlayMediaWithSubtitlesUseCaseFactoryImpl.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 26.08.22.
//

import Foundation

public final class PlayMediaWithSubtitlesUseCaseFactoryImpl: PlayMediaWithSubtitlesUseCaseFactory {
    
    public init() {}

    public func create(
        playMediaUseCase: PlayMediaUseCase,
        playSubtitlesUseCaseFactory: PlaySubtitlesUseCaseFactory,
        loadSubtitlesUseCase: LoadSubtitlesUseCase
    ) -> PlayMediaWithSubtitlesUseCase {
    
        return PlayMediaWithSubtitlesUseCaseImpl(
            playMediaUseCase: playMediaUseCase,
            playSubtitlesUseCaseFactory: playSubtitlesUseCaseFactory,
            loadSubtitlesUseCase: loadSubtitlesUseCase
        )
    }
}
