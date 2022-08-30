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
    private let subtitlesRepository: SubtitlesRepository
    private let subtitlesParser: SubtitlesParser
    private let subtitlesFilesRepository: FilesRepository
    
    // MARK: - Initializers
    
    public init(
        supportedExtensions: [String],
        subtitlesRepository: SubtitlesRepository,
        subtitlesParser: SubtitlesParser,
        subtitlesFilesRepository: FilesRepository
    ) {
        
        self.supportedExtensions = supportedExtensions
        self.subtitlesRepository = subtitlesRepository
        self.subtitlesParser = subtitlesParser
        self.subtitlesFilesRepository = subtitlesFilesRepository
    }
    
    // MARK: - Methods
    
    public func create() -> ImportSubtitlesUseCase {
        
        return ImportSubtitlesUseCaseImpl(
            supportedExtensions: supportedExtensions,
            subtitlesRepository: subtitlesRepository,
            subtitlesParser: subtitlesParser,
            subtitlesFilesRepository: subtitlesFilesRepository
        )
    }
}
