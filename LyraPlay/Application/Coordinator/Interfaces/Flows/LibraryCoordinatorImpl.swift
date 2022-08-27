//
//  LibraryCoordinatorImpl.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 26.08.22.
//

import Foundation


public final class LibraryCoordinatorImpl: LibraryCoordinator {
    
    // MARK: - Properties
    
    private let moduleFactory: LibraryModuleFactory
    
    private let browseAudioLibraryUseCaseFactory: () -> BrowseAudioLibraryUseCase
    private let importAudioFileUseCaseFactory: () -> ImportAudioFileUseCase
    
    // MARK: - Initializers
    
    public init(
        moduleFactory: LibraryModuleFactory,
        browseAudioLibraryUseCaseFactory: @escaping () -> BrowseAudioLibraryUseCase,
        importAudioFileUseCaseFactory: @escaping () -> ImportAudioFileUseCase
    ) {
        
        self.moduleFactory = moduleFactory
        self.browseAudioLibraryUseCaseFactory = browseAudioLibraryUseCaseFactory
        self.importAudioFileUseCaseFactory = importAudioFileUseCaseFactory
    }
    
    // MARK: - Methods

    public func runOpenLibraryItemFlow(mediaId: UUID) {
    }
    
    public func runImportMediaFilesFlow(completion: @escaping ([URL]?) -> Void) {
        
    }

    public func start(at presentationContainer: StackPresentationContainer) {
        
        let importAudioFileUseCase = importAudioFileUseCaseFactory()
        let browseAudioLibraryUseCase = browseAudioLibraryUseCaseFactory()

        let module = moduleFactory.create(
            coordinator: self,
            browseUseCase: browseAudioLibraryUseCase,
            importFileUseCase: importAudioFileUseCase
        )

        presentationContainer.setRoot(module)
    }
}
