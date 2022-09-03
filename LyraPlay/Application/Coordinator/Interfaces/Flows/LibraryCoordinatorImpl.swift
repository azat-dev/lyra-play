//
//  LibraryCoordinatorImpl.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 26.08.22.
//

import Foundation


public final class LibraryCoordinatorImpl<ModuleFactory, ViewModelFactory>: BaseCoordinator, LibraryCoordinator
    where ModuleFactory: LibraryModuleFactory,
    ViewModelFactory: AudioFilesBrowserViewModelFactory,
    ModuleFactory.ViewFactory.ViewModel == ViewModelFactory.ViewModel {
    
    // MARK: - Properties
    
    private let moduleFactory: ModuleFactory
    private let viewModelFactory: ViewModelFactory
    
    private let browseAudioLibraryUseCaseFactory: () -> BrowseAudioLibraryUseCase
    private let importAudioFileUseCaseFactory: () -> ImportAudioFileUseCase
    
    private var container: PresentationContainer?
    
    // MARK: - Initializers
    
    public init(
        moduleFactory: ModuleFactory,
        viewModelFactory: ViewModelFactory,
        browseAudioLibraryUseCaseFactory: @escaping () -> BrowseAudioLibraryUseCase,
        importAudioFileUseCaseFactory: @escaping () -> ImportAudioFileUseCase
    ) {
        
        
        self.moduleFactory = moduleFactory
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
        
        let module = moduleFactory.create(viewModel: viewModel)

        container = presentationContainer
        presentationContainer.setRoot(module)
    }
}
