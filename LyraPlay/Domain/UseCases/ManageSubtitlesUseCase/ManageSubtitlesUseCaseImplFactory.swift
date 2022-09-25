//
//  ManageSubtitlesUseCaseImplFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 15.09.2022.
//

import Foundation

public final class ManageSubtitlesUseCaseImplFactory: ManageSubtitlesUseCaseFactory {

    // MARK: - Properties

    private let subtitlesRepository: SubtitlesRepository
    private let subtitlesFilesRepository: FilesRepository

    // MARK: - Initializers

    public init(
        subtitlesRepository: SubtitlesRepository,
        subtitlesFilesRepository: FilesRepository
    ) {

        self.subtitlesRepository = subtitlesRepository
        self.subtitlesFilesRepository = subtitlesFilesRepository
    }

    // MARK: - Methods

    public func create() -> ManageSubtitlesUseCase {

        return ManageSubtitlesUseCaseImpl(
            subtitlesRepository: subtitlesRepository,
            subtitlesFilesRepository: subtitlesFilesRepository
        )
    }
}