//
//  LibraryFlowImpl.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 26.08.22.
//

import Foundation

public final class LibraryFlowImpl: LibraryFlow {
    
    // MARK: - Properties
    
    private let moduleFactory: LibraryModuleFactory
    
    private let browseAudioLibraryUseCaseFactory: BrowseAudioLibraryUseCaseFactory
    private let importAudioFileUseCaseFactory: ImportAudioFileUseCaseFactory
    
    private let tagsParserFactory: TagsParserFactory
    
    // MARK: - Initializers
    
    public init(
        moduleFactory: LibraryModuleFactory,
        browseAudioLibraryUseCaseFactory: BrowseAudioLibraryUseCaseFactory,
        tagsParserFactory: TagsParserFactory
    ) {
        
        self.moduleFactory = moduleFactory
        self.tagsParserFactory = tagsParserFactory
    }
    
    public func runImportMediaFilesFlow() {
        
    }
    
    public func runOpenLibraryItemFlow(mediaId: UUID) {
        
        
    }
    
    // MARK: - Methods
    
    public func start(
        at presentationContainer: StackPresentationContainer,
        audioLibraryRepository: AudioLibraryRepository,
        audioFilesRepository: FilesRepository,
        imagesRepository: FilesRepository
    ) {
        
        let tagsParser = tagsParserFactory.create()
        
        let importAudioFileUseCase = importAudioFileUseCaseFactory.create(
            audioLibraryRepository: audioLibraryRepository,
            audioFilesRepository: audioFilesRepository,
            imagesRepository: imagesRepository,
            tagsParser: tagsParser
        )
        
        let browseAudioLibraryUseCase = browseAudioLibraryUseCaseFactory.create(
            audioLibraryRepository: audioLibraryRepository,
            imagesRepository: imagesRepository
        )
        
        let module = moduleFactory.create(
            browseUseCase: browseAudioLibraryUseCase,
            importFileUseCase: importAudioFileUseCase,
            importMediaFilesFlow:
        )
        
        presentationContainer.setRoot(module)
    }
}
