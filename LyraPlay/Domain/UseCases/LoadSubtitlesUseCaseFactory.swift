//
//  LoadSubtitlesUseCaseFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 26.08.22.
//

import Foundation

public protocol LoadSubtitlesUseCaseFactory {
    
    func create(
        subtitlesRepository: SubtitlesRepository,
        subtitlesFiles: FilesRepository,
        subtitlesParser: SubtitlesParser
    ) -> LoadSubtitlesUseCase
}
