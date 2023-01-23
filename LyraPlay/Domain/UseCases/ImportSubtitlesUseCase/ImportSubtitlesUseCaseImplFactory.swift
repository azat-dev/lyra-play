//
//  ImportSubtitlesUseCaseImplFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 30.08.2022.
//

import Foundation

public final class ImportSubtitlesUseCaseImplFactory: ImportSubtitlesUseCaseFactory {
    
    // MARK: - Properties
    
    private let supportedExtensions: [String]
    private let subtitlesRepositoryFactory: SubtitlesRepositoryFactory
    private let subtitlesParserFactory: SubtitlesParserFactory
    private let subtitlesFilesRepository: FilesRepository
    
    // MARK: - Initializers
    
    public init(
        supportedExtensions: [String],
        subtitlesRepositoryFactory: SubtitlesRepositoryFactory,
        subtitlesParserFactory: SubtitlesParserFactory,
        subtitlesFilesRepository: FilesRepository
    ) {
        
        self.supportedExtensions = supportedExtensions
        self.subtitlesRepositoryFactory = subtitlesRepositoryFactory
        self.subtitlesParserFactory = subtitlesParserFactory
        self.subtitlesFilesRepository = subtitlesFilesRepository
    }
    
    // MARK: - Methods
    
    public func create() -> ImportSubtitlesUseCase {
        
        let subtitlesRepository = subtitlesRepositoryFactory.create()
        let subtitlesParser = subtitlesParserFactory.create()
        
        return ImportSubtitlesUseCaseImpl(
            supportedExtensions: supportedExtensions,
            subtitlesRepository: subtitlesRepository,
            subtitlesParser: subtitlesParser,
            subtitlesFilesRepository: subtitlesFilesRepository
        )
    }
}
