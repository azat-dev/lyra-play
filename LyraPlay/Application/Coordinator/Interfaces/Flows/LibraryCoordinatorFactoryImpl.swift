//
//  LibraryCoordinatorFactoryImpl.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 03.09.22.
//

import Foundation

public final class LibraryCoordinatorFactoryImpl<M,V>: LibraryCoordinatorFactory
where M: LibraryModuleFactory, V: AudioFilesBrowserViewModelFactory {
    
    private let moduleFactory: M
    private let viewModelFactory: V
    
    public init(
        moduleFactory: M,
        viewModelFactory: V
    ) {
        
        self.moduleFactory = moduleFactory
        self.viewModelFactory = viewModelFactory
    }
    
    public func create() -> LibraryCoordinator {
        fatalError()
//        return LibraryCoordinatorImpl(
//            moduleFactory: moduleFactory,
//            viewModelFactory: viewModelFactory,
//            browseAudioLibraryUseCaseFactory: <#T##() -> BrowseAudioLibraryUseCase#>,
//            importAudioFileUseCaseFactory: <#T##() -> ImportAudioFileUseCase#>
//        )
    }
}
