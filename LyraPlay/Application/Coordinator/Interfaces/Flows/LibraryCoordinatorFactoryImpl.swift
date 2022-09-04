//
//  LibraryCoordinatorFactoryImpl.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 03.09.22.
//

import Foundation

public final class LibraryCoordinatorFactoryImpl: LibraryCoordinatorFactory {
    
    private let viewModelFactory: AudioFilesBrowserViewModelFactory
    private let viewFactory: AudioFilesBrowserViewFactory
    
    public init(
        viewModelFactory: AudioFilesBrowserViewModelFactory,
        viewFactory: AudioFilesBrowserViewFactory
    ) {
        
        self.viewFactory = viewFactory
        self.viewModelFactory = viewModelFactory
    }
    
    public func create() -> LibraryCoordinator {
        
        return LibraryCoordinatorImpl(
            viewModelFactory: viewModelFactory,
            viewFactory: viewFactory,
            browseAudioLibraryUseCaseFactory: { fatalError() },
            importAudioFileUseCaseFactory: { fatalError() }
        )
    }
}
