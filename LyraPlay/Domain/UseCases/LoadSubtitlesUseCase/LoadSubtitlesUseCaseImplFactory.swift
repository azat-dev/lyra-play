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
    private let subtitlesParser: SubtitlesParser

    // MARK: - Initializers

    public init(
        subtitlesRepository: SubtitlesRepository,
        subtitlesFiles: FilesRepository,
        subtitlesParser: SubtitlesParser
    ) {

        self.subtitlesRepository = subtitlesRepository
        self.subtitlesFiles = subtitlesFiles
        self.subtitlesParser = subtitlesParser
    }

    // MARK: - Methods

    public func create() -> LoadSubtitlesUseCase {

        return LoadSubtitlesUseCaseImpl(
            subtitlesRepository: subtitlesRepository,
            subtitlesFiles: subtitlesFiles,
            subtitlesParser: subtitlesParser
        )
    }
}
