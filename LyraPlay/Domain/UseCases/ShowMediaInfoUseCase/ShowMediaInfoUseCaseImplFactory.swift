//
//  ShowMediaInfoUseCaseImplFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 01.09.2022.
//

import Foundation

public final class ShowMediaInfoUseCaseImplFactory: ShowMediaInfoUseCaseFactory {

    // MARK: - Properties

    private let audioLibraryRepository: AudioLibraryRepository
    private let imagesRepository: FilesRepository
    private let defaultImage: Data

    // MARK: - Initializers

    public init(
        audioLibraryRepository: AudioLibraryRepository,
        imagesRepository: FilesRepository,
        defaultImage: Data
    ) {

        self.audioLibraryRepository = audioLibraryRepository
        self.imagesRepository = imagesRepository
        self.defaultImage = defaultImage
    }

    // MARK: - Methods

    public func create() -> ShowMediaInfoUseCase {

        return ShowMediaInfoUseCaseImpl(
            audioLibraryRepository: audioLibraryRepository,
            imagesRepository: imagesRepository,
            defaultImage: defaultImage
        )
    }

}