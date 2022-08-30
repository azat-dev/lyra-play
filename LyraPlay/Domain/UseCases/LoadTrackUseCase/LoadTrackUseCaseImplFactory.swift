//
//  LoadTrackUseCaseImplFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 30.08.2022.
//

import Foundation

public final class LoadTrackUseCaseImplFactory: LoadTrackUseCaseFactory {

    // MARK: - Properties

    private let audioLibraryRepository: AudioLibraryRepository
    private let audioFilesRepository: FilesRepository

    // MARK: - Initializers

    public init(
        audioLibraryRepository: AudioLibraryRepository,
        audioFilesRepository: FilesRepository
    ) {

        self.audioLibraryRepository = audioLibraryRepository
        self.audioFilesRepository = audioFilesRepository
    }

    // MARK: - Methods

    public func create() -> LoadTrackUseCase {

        return LoadTrackUseCaseImpl(
            audioLibraryRepository: audioLibraryRepository,
            audioFilesRepository: audioFilesRepository
        )
    }

}