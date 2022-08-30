//
//  BrowseAudioLibraryUseCaseImplFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 30.08.2022.
//

import Foundation

public final class BrowseAudioLibraryUseCaseImplFactory: BrowseAudioLibraryUseCaseFactory {

    // MARK: - Properties

    private let audioLibraryRepository: AudioLibraryRepository
    private let imagesRepository: FilesRepository

    // MARK: - Initializers

    public init(
        audioLibraryRepository: AudioLibraryRepository,
        imagesRepository: FilesRepository
    ) {

        self.audioLibraryRepository = audioLibraryRepository
        self.imagesRepository = imagesRepository
    }

    // MARK: - Methods

    public func create() -> BrowseAudioLibraryUseCase {

        return BrowseAudioLibraryUseCaseImpl(
            audioLibraryRepository: audioLibraryRepository,
            imagesRepository: imagesRepository
        )
    }
}
