//
//  LoadTrackUseCaseImplFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 30.08.2022.
//

import Foundation

public final class LoadTrackUseCaseImplFactory: LoadTrackUseCaseFactory {

    // MARK: - Properties

    private let mediaLibraryRepository: MediaLibraryRepository
    private let audioFilesRepository: FilesRepository

    // MARK: - Initializers

    public init(
        mediaLibraryRepository: MediaLibraryRepository,
        audioFilesRepository: FilesRepository
    ) {

        self.mediaLibraryRepository = mediaLibraryRepository
        self.audioFilesRepository = audioFilesRepository
    }

    // MARK: - Methods

    public func create() -> LoadTrackUseCase {

        return LoadTrackUseCaseImpl(
            mediaLibraryRepository: mediaLibraryRepository,
            audioFilesRepository: audioFilesRepository
        )
    }

}
