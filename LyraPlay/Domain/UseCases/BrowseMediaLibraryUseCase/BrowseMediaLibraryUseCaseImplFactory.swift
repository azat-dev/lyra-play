//
//  BrowseMediaLibraryUseCaseImplFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 30.08.2022.
//

import Foundation

public final class BrowseMediaLibraryUseCaseImplFactory: BrowseMediaLibraryUseCaseFactory {

    // MARK: - Properties

    private let mediaLibraryRepository: MediaLibraryRepository
    private let imagesRepository: FilesRepository

    // MARK: - Initializers

    public init(
        mediaLibraryRepository: MediaLibraryRepository,
        imagesRepository: FilesRepository
    ) {

        self.mediaLibraryRepository = mediaLibraryRepository
        self.imagesRepository = imagesRepository
    }

    // MARK: - Methods

    public func make() -> BrowseMediaLibraryUseCase {

        return BrowseMediaLibraryUseCaseImpl(
            mediaLibraryRepository: mediaLibraryRepository,
            imagesRepository: imagesRepository
        )
    }
}
