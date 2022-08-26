//
//  LibraryModuleFactoryImpl.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 26.08.22.
//

import Foundation

public final class LibraryModuleFactoryImpl: LibraryModuleFactory {
    
    private let viewModelFactory: AudioFilesBrowserViewModelFactory
    private let viewFactory: AudioFilesBrowserViewFactory
    
    public init(viewModelFactory: AudioFilesBrowserViewModelFactory, viewFactory: AudioFilesBrowserViewFactory) {
        
        self.viewModelFactory = viewModelFactory
        self.viewFactory = viewFactory
    }
    
    public func create(
        coordinator: LibraryCoordinator,
        browseUseCase: BrowseAudioLibraryUseCase,
        importFileUseCase: ImportAudioFileUseCase
    ) -> PresentableModuleImpl<AudioFilesBrowserViewModel> {
        
        let viewModel = viewModelFactory.create(
            coordinator: coordinator,
            browseUseCase: browseUseCase,
            importFileUseCase: importFileUseCase
        )
        
        let view = viewFactory.create(viewModel: viewModel)
        
        return .init(
            view: view,
            model: viewModel
        )
    }
}
