//
//  ShowMediaInfoUseCaseImplFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 01.09.2022.
//

import Foundation

public final class ShowMediaInfoUseCaseImplFactory: ShowMediaInfoUseCaseFactory {

    // MARK: - Properties

    private let mediaLibraryRepository: MediaLibraryRepository
    private let imagesRepository: FilesRepository
    private let defaultImage: Data

    // MARK: - Initializers

    public init(
        mediaLibraryRepository: MediaLibraryRepository,
        imagesRepository: FilesRepository,
        defaultImage: Data
    ) {

        self.mediaLibraryRepository = mediaLibraryRepository
        self.imagesRepository = imagesRepository
        self.defaultImage = defaultImage
    }

    // MARK: - Methods

    public func make() -> ShowMediaInfoUseCase {

        return ShowMediaInfoUseCaseImpl(
            mediaLibraryRepository: mediaLibraryRepository,
            imagesRepository: imagesRepository,
            defaultImage: defaultImage
        )
    }

}
