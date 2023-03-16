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
    private let importSubtitlesUseCaseFactory: ImportSubtitlesUseCaseFactory

    // MARK: - Initializers

    public init(
        mediaLibraryRepository: MediaLibraryRepository,
        audioFilesRepository: FilesRepository,
        imagesRepository: FilesRepository,
        tagsParserFactory: TagsParserFactory,
        fileNameGenerator: ImportAudioFileUseCaseFileNameGenerator,
        importSubtitlesUseCaseFactory: ImportSubtitlesUseCaseFactory
    ) {

        self.mediaLibraryRepository = mediaLibraryRepository
        self.audioFilesRepository = audioFilesRepository
        self.imagesRepository = imagesRepository
        self.tagsParserFactory = tagsParserFactory
        self.fileNameGenerator = fileNameGenerator
        self.importSubtitlesUseCaseFactory = importSubtitlesUseCaseFactory
    }

    // MARK: - Methods

    public func make() -> ImportAudioFileUseCase {
        
        let tagsParser = tagsParserFactory.make()

        return ImportAudioFileUseCaseImpl(
            mediaLibraryRepository: mediaLibraryRepository,
            audioFilesRepository: audioFilesRepository,
            imagesRepository: imagesRepository,
            tagsParser: tagsParser,
            fileNameGenerator: fileNameGenerator,
            importSubtitlesUseCaseFactory: importSubtitlesUseCaseFactory
        )
    }
}
