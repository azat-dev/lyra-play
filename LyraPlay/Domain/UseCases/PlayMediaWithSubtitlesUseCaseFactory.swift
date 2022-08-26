//
//  PlayMediaWithSubtitlesUseCaseFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 26.08.22.
//

import Foundation

public protocol PlayMediaWithSubtitlesUseCaseFactory {
    
    func create(
        playMediaUseCase: PlayMediaUseCase,
        playSubtitlesUseCaseFactory: PlaySubtitlesUseCaseFactory,
        loadSubtitlesUseCase: LoadSubtitlesUseCase
    ) -> PlayMediaWithSubtitlesUseCase
}
