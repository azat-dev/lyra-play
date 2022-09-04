//
//  LibraryCoordinatorImpl.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 26.08.22.
//

import Foundation


public final class LibraryCoordinatorImpl: BaseCoordinator, LibraryCoordinator {
    
    // MARK: - Properties
    
    private let viewFactory: AudioFilesBrowserViewFactory
    private let viewModelFactory: AudioFilesBrowserViewModelFactory
    
    private let browseAudioLibraryUseCaseFactory: () -> BrowseAudioLibraryUseCase
    private let importAudioFileUseCaseFactory: () -> ImportAudioFileUseCase
    
    private var container: PresentationContainer?
    
    // MARK: - Initializers
    
    public init(
        viewModelFactory: AudioFilesBrowserViewModelFactory,
        viewFactory: AudioFilesBrowserViewFactory,
        browseAudioLibraryUseCaseFactory: @escaping () -> BrowseAudioLibraryUseCase,
        importAudioFileUseCaseFactory: @escaping () -> ImportAudioFileUseCase
    ) {
        
        
        self.viewFactory = viewFactory
        self.viewModelFactory = viewModelFactory
        
        self.browseAudioLibraryUseCaseFactory = browseAudioLibraryUseCaseFactory
        self.importAudioFileUseCaseFactory = importAudioFileUseCaseFactory
        
        super.init()
    }
    
    // MARK: - Methods

    public func runOpenLibraryItemFlow(mediaId: UUID) {
    }
    
    public func runImportMediaFilesFlow(completion: @escaping ([URL]?) -> Void) {
    }

    public func start(at presentationContainer: StackPresentationContainer) {
        
        let importAudioFileUseCase = importAudioFileUseCaseFactory()
        let browseAudioLibraryUseCase = browseAudioLibraryUseCaseFactory()

        let viewModel = viewModelFactory.create(
            coordinator: self,
            browseUseCase: browseAudioLibraryUseCase,
            importFileUseCase: importAudioFileUseCase
        )
        
        let view = viewFactory.create(viewModel: viewModel)

        container = presentationContainer
        presentationContainer.setRoot(view)
    }
}
