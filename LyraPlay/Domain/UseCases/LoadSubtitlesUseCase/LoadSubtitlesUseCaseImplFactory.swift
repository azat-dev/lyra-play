//
//  LoadSubtitlesUseCaseImplFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 30.08.2022.
//

import Foundation

public final class LoadSubtitlesUseCaseImplFactory: LoadSubtitlesUseCaseFactory {

    // MARK: - Properties

    private let subtitlesRepositoryFactory: SubtitlesRepositoryFactory
    private let subtitlesFiles: FilesRepository
    private let subtitlesParserFactory: SubtitlesParserFactory

    // MARK: - Initializers

    public init(
        subtitlesRepositoryFactory: SubtitlesRepositoryFactory,
        subtitlesFiles: FilesRepository,
        subtitlesParserFactory: SubtitlesParserFactory
    ) {

        self.subtitlesRepositoryFactory = subtitlesRepositoryFactory
        self.subtitlesFiles = subtitlesFiles
        self.subtitlesParserFactory = subtitlesParserFactory
    }

    // MARK: - Methods

    public func make() -> LoadSubtitlesUseCase {

        let subtitlesRepository = subtitlesRepositoryFactory.make()
        let subtitlesParser = subtitlesParserFactory.make()
        
        return LoadSubtitlesUseCaseImpl(
            subtitlesRepository: subtitlesRepository,
            subtitlesFiles: subtitlesFiles,
            subtitlesParser: subtitlesParser
        )
    }
}
