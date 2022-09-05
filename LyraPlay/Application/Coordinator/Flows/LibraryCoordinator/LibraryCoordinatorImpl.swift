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
    
    private let libraryItemCoordinatorFactory: LibraryItemCoordinatorFactory
    
    private weak var container: StackPresentationContainer?
    
    // MARK: - Initializers
    
    public init(
        viewModelFactory: AudioFilesBrowserViewModelFactory,
        viewFactory: AudioFilesBrowserViewFactory,
        libraryItemCoordinatorFactory: LibraryItemCoordinatorFactory
    ) {
        
        self.viewFactory = viewFactory
        self.viewModelFactory = viewModelFactory
        self.libraryItemCoordinatorFactory = libraryItemCoordinatorFactory
        
        super.init()
    }
    
    // MARK: - Methods

    public func runOpenLibraryItemFlow(mediaId: UUID) {
        
        guard
            let container = container,
            !children.contains(where: { $0 is LibraryItemCoordinator })
        else {
            return
        }
        
        let libraryItemCoordinator = libraryItemCoordinatorFactory.create()
        addChild(libraryItemCoordinator)
        libraryItemCoordinator.start(at: container, mediaId: mediaId)
    }
    
    public func runImportMediaFilesFlow(completion: @escaping ([URL]?) -> Void) {
    }

    public func start(at presentationContainer: StackPresentationContainer) {
        
        let viewModel = viewModelFactory.create(coordinator: self)
        let view = viewFactory.create(viewModel: viewModel)

        container = presentationContainer
        presentationContainer.setRoot(view)
    }
}
