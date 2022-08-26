//
//  LoadSubtitlesUseCaseFactoryImpl.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 26.08.22.
//

import Foundation

public final class LoadSubtitlesUseCaseFactoryImpl: LoadSubtitlesUseCaseFactory {
    
    public init() {}
    
    public func create(
        subtitlesRepository: SubtitlesRepository,
        subtitlesFiles: FilesRepository,
        subtitlesParser: SubtitlesParser
    ) -> LoadSubtitlesUseCase {
        
        return LoadSubtitlesUseCaseImpl(
            subtitlesRepository: subtitlesRepository,
            subtitlesFiles: subtitlesFiles,
            subtitlesParser: subtitlesParser
        )
    }
}
