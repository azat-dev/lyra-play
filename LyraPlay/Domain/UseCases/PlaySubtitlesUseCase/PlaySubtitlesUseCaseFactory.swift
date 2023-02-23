//
//  PlaySubtitlesUseCaseFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 31.08.2022.
//

public protocol PlaySubtitlesUseCaseFactory {

    func make(
        subtitles: Subtitles,
        delegate: PlaySubtitlesUseCaseDelegate?
    ) -> PlaySubtitlesUseCase
}
