//
//  LibraryCoordinatorFactoryImpl.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 03.09.22.
//

import Foundation

public final class LibraryCoordinatorFactoryImpl: LibraryCoordinatorFactory {
    
    // MARK: - Properties
    
    private let viewModelFactory: AudioFilesBrowserViewModelFactory
    private let viewFactory: AudioFilesBrowserViewFactory
    private let libraryItemCoordinatorFactory: LibraryItemCoordinatorFactory
    
    // MARK: - Initializers
    
    public init(
        viewModelFactory: AudioFilesBrowserViewModelFactory,
        viewFactory: AudioFilesBrowserViewFactory,
        libraryItemCoordinatorFactory: LibraryItemCoordinatorFactory
    ) {
        
        self.viewFactory = viewFactory
        self.viewModelFactory = viewModelFactory
        self.libraryItemCoordinatorFactory = libraryItemCoordinatorFactory
    }
    
    // MARK: - Methods
    
    public func create() -> LibraryCoordinator {
        
        return LibraryCoordinatorImpl(
            viewModelFactory: viewModelFactory,
            viewFactory: viewFactory,
            libraryItemCoordinatorFactory: libraryItemCoordinatorFactory
        )
    }
}
