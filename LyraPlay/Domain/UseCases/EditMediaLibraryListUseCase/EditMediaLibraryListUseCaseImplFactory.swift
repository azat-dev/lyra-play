//
//  EditMediaLibraryListUseCaseImplFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 14.09.2022.
//

import Foundation

public final class EditMediaLibraryListUseCaseImplFactory: EditMediaLibraryListUseCaseFactory {

    // MARK: - Properties

    private let mediaLibraryRepository: MediaLibraryRepository
    private let mediaFilesRepository: FilesRepository
    private let subtitlesRepository: SubtitlesRepository
    private let imagesRepository: FilesRepository

    // MARK: - Initializers

    public init(
        mediaLibraryRepository: MediaLibraryRepository,
        mediaFilesRepository: FilesRepository,
        subtitlesRepository: SubtitlesRepository,
        imagesRepository: FilesRepository
    ) {

        self.mediaLibraryRepository = mediaLibraryRepository
        self.mediaFilesRepository = mediaFilesRepository
        self.subtitlesRepository = subtitlesRepository
        self.imagesRepository = imagesRepository
    }

    // MARK: - Methods

    public func create() -> EditMediaLibraryListUseCase {

        return EditMediaLibraryListUseCaseImpl(
            mediaLibraryRepository: mediaLibraryRepository,
            mediaFilesRepository: mediaFilesRepository,
            subtitlesRepository: subtitlesRepository,
            imagesRepository: imagesRepository
        )
    }
}