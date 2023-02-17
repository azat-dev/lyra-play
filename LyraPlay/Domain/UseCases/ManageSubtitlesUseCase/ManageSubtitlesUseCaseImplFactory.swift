//
//  ManageSubtitlesUseCaseImplFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 15.09.2022.
//

import Foundation

public final class ManageSubtitlesUseCaseImplFactory: ManageSubtitlesUseCaseFactory {
    
    // MARK: - Properties
    
    private let subtitlesRepositoryFactory: SubtitlesRepositoryFactory
    private let subtitlesFilesRepository: FilesRepository
    
    // MARK: - Initializers
    
    public init(
        subtitlesRepositoryFactory: SubtitlesRepositoryFactory,
        subtitlesFilesRepository: FilesRepository
    ) {
        
        self.subtitlesRepositoryFactory = subtitlesRepositoryFactory
        self.subtitlesFilesRepository = subtitlesFilesRepository
    }
    
    // MARK: - Methods
    
    public func make() -> ManageSubtitlesUseCase {
        
        let subtitlesRepository = subtitlesRepositoryFactory.make()
        
        return ManageSubtitlesUseCaseImpl(
            subtitlesRepository: subtitlesRepository,
            subtitlesFilesRepository: subtitlesFilesRepository
        )
    }
}
