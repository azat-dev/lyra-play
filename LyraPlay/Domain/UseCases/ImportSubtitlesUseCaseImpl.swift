//
//  ImportSubtitlesUseCaseImpl.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 26.08.22.
//

import Foundation

public final class ImportSubtitlesUseCaseFactoryImpl: ImportSubtitlesUseCaseFactory {
    
    public init() {}
    
    public func create(
        subtitlesRepository: SubtitlesRepository,
        subtitlesParser: SubtitlesParser,
        subtitlesFilesRepository: FilesRepository,
        supportedExtensions: [String]
    ) -> ImportSubtitlesUseCase {
        
        return ImportSubtitlesUseCaseImpl(
            subtitlesRepository: subtitlesRepository,
            subtitlesParser: subtitlesParser,
            subtitlesFilesRepository: subtitlesFilesRepository,
            supportedExtensions: supportedExtensions
        )
    }
}
