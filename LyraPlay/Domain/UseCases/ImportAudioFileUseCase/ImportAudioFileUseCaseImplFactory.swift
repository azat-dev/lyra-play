//
//  ImportAudioFileUseCaseImplFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 30.08.2022.
//

import Foundation

public final class ImportAudioFileUseCaseImplFactory: ImportAudioFileUseCaseFactory {

    // MARK: - Properties

    private let mediaLibraryRepository: MediaLibraryRepository
    private let audioFilesRepository: FilesRepository
    private let imagesRepository: FilesRepository
    private let tagsParserFactory: TagsParserFactory
    private let fileNameGenerator: ImportAudioFileUseCaseFileNameGenerator

    // MARK: - Initializers

    public init(
        mediaLibraryRepository: MediaLibraryRepository,
        audioFilesRepository: FilesRepository,
        imagesRepository: FilesRepository,
        tagsParserFactory: TagsParserFactory,
        fileNameGenerator: ImportAudioFileUseCaseFileNameGenerator
    ) {

        self.mediaLibraryRepository = mediaLibraryRepository
        self.audioFilesRepository = audioFilesRepository
        self.imagesRepository = imagesRepository
        self.tagsParserFactory = tagsParserFactory
        self.fileNameGenerator = fileNameGenerator
    }

    // MARK: - Methods

    public func create() -> ImportAudioFileUseCase {
        
        let tagsParser = tagsParserFactory.create()

        return ImportAudioFileUseCaseImpl(
            mediaLibraryRepository: mediaLibraryRepository,
            audioFilesRepository: audioFilesRepository,
            imagesRepository: imagesRepository,
            tagsParser: tagsParser,
            fileNameGenerator: fileNameGenerator
        )
    }
}
