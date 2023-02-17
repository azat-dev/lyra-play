//
//  EditMediaLibraryListUseCaseImplFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 14.09.2022.
//

import Foundation

public final class EditMediaLibraryListUseCaseImplFactory: EditMediaLibraryListUseCaseFactory {
    
    // MARK: - Properties
    
    private let mediaLibraryRepository: MediaLibraryRepository
    private let mediaFilesRepository: FilesRepository
    private let manageSubtitlesUseCaseFactory: ManageSubtitlesUseCaseFactory
    private let imagesRepository: FilesRepository
    
    // MARK: - Initializers
    
    public init(
        mediaLibraryRepository: MediaLibraryRepository,
        mediaFilesRepository: FilesRepository,
        manageSubtitlesUseCaseFactory: ManageSubtitlesUseCaseFactory,
        imagesRepository: FilesRepository
    ) {
        
        self.mediaLibraryRepository = mediaLibraryRepository
        self.mediaFilesRepository = mediaFilesRepository
        self.manageSubtitlesUseCaseFactory = manageSubtitlesUseCaseFactory
        self.imagesRepository = imagesRepository
    }
    
    // MARK: - Methods
    
    public func make() -> EditMediaLibraryListUseCase {
        
        let manageSubtitlesUseCase = manageSubtitlesUseCaseFactory.make()
        
        return EditMediaLibraryListUseCaseImpl(
            mediaLibraryRepository: mediaLibraryRepository,
            mediaFilesRepository: mediaFilesRepository,
            manageSubtitlesUseCase: manageSubtitlesUseCase,
            imagesRepository: imagesRepository
        )
    }
}
