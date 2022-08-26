//
//  AudioFilesBrowserViewControllerFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 27.06.22.
//

import Foundation

final class AudioFilesBrowserViewControllerFactoryDeprecated {
    
    private let browseFilesUseCase: BrowseAudioLibraryUseCase
    private let importFileUseCase: ImportAudioFileUseCase
    private let coordinator: LibraryCoordinator
    
    init(
        coordinator: LibraryCoordinator,
        browseFilesUseCase: BrowseAudioLibraryUseCase,
        importFileUseCase: ImportAudioFileUseCase
    ) {
        
        self.browseFilesUseCase = browseFilesUseCase
        self.importFileUseCase = importFileUseCase
        self.coordinator = coordinator
    }
    
    func build() -> AudioFilesBrowserViewController {
        
        let viewModel = AudioFilesBrowserViewModelImpl(
            coordinator: coordinator,
            browseUseCase: browseFilesUseCase,
            importFileUseCase: importFileUseCase
        )
        return AudioFilesBrowserViewController(viewModel: viewModel)
    }
}
