//
//  LibraryItemCoordinatorImpl.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 05.09.2022.
//

import Foundation

public final class LibraryItemCoordinatorImpl: BaseCoordinator, LibraryItemCoordinator {
    
    // MARK: - Properties
    
    private let viewModelFactory: LibraryItemViewModelFactory
    private let viewFactory: LibraryItemViewFactory
    
    // MARK: - Initializers
    
    public init(
        viewModelFactory: LibraryItemViewModelFactory,
        viewFactory: LibraryItemViewFactory
    ) {
        
        self.viewModelFactory = viewModelFactory
        self.viewFactory = viewFactory
        
        super.init()
    }
    
    // MARK: - Methods
    
    public func start(at container: StackPresentationContainer, mediaId: UUID) {
        
        let viewModel = viewModelFactory.create(mediaId: mediaId, coordinator: self)
        let view = viewFactory.create(viewModel: viewModel)
        
        container.push(view)
    }
}

// MARK: - Input Methods

extension LibraryItemCoordinatorImpl {
    
    public func runAttachSubtitlesFlow(completion: @escaping (_ url: URL?) -> Void) {
    }
}
