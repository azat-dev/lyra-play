//
//  LoadSubtitlesUseCaseImplFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 30.08.2022.
//

import Foundation

public final class LoadSubtitlesUseCaseImplFactory: LoadSubtitlesUseCaseFactory {

    // MARK: - Properties

    private let subtitlesRepository: SubtitlesRepository
    private let subtitlesFiles: FilesRepository
    private let subtitlesParserFactory: SubtitlesParserFactory

    // MARK: - Initializers

    public init(
        subtitlesRepository: SubtitlesRepository,
        subtitlesFiles: FilesRepository,
        subtitlesParserFactory: SubtitlesParserFactory
    ) {

        self.subtitlesRepository = subtitlesRepository
        self.subtitlesFiles = subtitlesFiles
        self.subtitlesParserFactory = subtitlesParserFactory
    }

    // MARK: - Methods

    public func create() -> LoadSubtitlesUseCase {

        let subtitlesParser = subtitlesParserFactory.create()
        
        return LoadSubtitlesUseCaseImpl(
            subtitlesRepository: subtitlesRepository,
            subtitlesFiles: subtitlesFiles,
            subtitlesParser: subtitlesParser
        )
    }
}
