//
//  ImportSubtitlesUseCaseFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 26.08.22.
//

import Foundation

public protocol ImportSubtitlesUseCaseFactory {
    
    func create(
        subtitlesRepository: SubtitlesRepository,
        subtitlesParser: SubtitlesParser,
        subtitlesFilesRepository: FilesRepository,
        supportedExtensions: [String]
    ) -> ImportSubtitlesUseCase
}

