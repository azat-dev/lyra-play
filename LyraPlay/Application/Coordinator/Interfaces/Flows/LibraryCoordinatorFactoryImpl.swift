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
    private let browseAudioLibraryUseCaseFactory: BrowseAudioLibraryUseCaseFactory
    private let importAudioFileUseCaseFactory: ImportAudioFileUseCaseFactory
    
    public init(
        viewModelFactory: AudioFilesBrowserViewModelFactory,
        viewFactory: AudioFilesBrowserViewFactory,
        browseAudioLibraryUseCaseFactory: BrowseAudioLibraryUseCaseFactory,
        importAudioFileUseCaseFactory: ImportAudioFileUseCaseFactory
    ) {
        
        self.viewFactory = viewFactory
        self.viewModelFactory = viewModelFactory
        self.browseAudioLibraryUseCaseFactory = browseAudioLibraryUseCaseFactory
        self.importAudioFileUseCaseFactory = importAudioFileUseCaseFactory
    }
    
    public func create() -> LibraryCoordinator {
        
        return LibraryCoordinatorImpl(
            viewModelFactory: viewModelFactory,
            viewFactory: viewFactory,
            browseAudioLibraryUseCaseFactory: browseAudioLibraryUseCaseFactory,
            importAudioFileUseCaseFactory: importAudioFileUseCaseFactory
        )
    }
}
