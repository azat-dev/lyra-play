//
//  ImportAudioFileUseCaseImplFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 30.08.2022.
//

import Foundation

public final class ImportAudioFileUseCaseImplFactory: ImportAudioFileUseCaseFactory {

    // MARK: - Properties

    private let audioLibraryRepository: AudioLibraryRepository
    private let audioFilesRepository: FilesRepository
    private let imagesRepository: FilesRepository
    private let tagsParser: TagsParser

    // MARK: - Initializers

    public init(
        audioLibraryRepository: AudioLibraryRepository,
        audioFilesRepository: FilesRepository,
        imagesRepository: FilesRepository,
        tagsParser: TagsParser
    ) {

        self.audioLibraryRepository = audioLibraryRepository
        self.audioFilesRepository = audioFilesRepository
        self.imagesRepository = imagesRepository
        self.tagsParser = tagsParser
    }

    // MARK: - Methods

    public func create() -> ImportAudioFileUseCase {

        return ImportAudioFileUseCaseImpl(
            audioLibraryRepository: audioLibraryRepository,
            audioFilesRepository: audioFilesRepository,
            imagesRepository: imagesRepository,
            tagsParser: tagsParser
        )
    }
}
