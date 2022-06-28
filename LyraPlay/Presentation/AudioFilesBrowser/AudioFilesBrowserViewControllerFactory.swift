//
//  AudioFilesBrowserViewControllerFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 27.06.22.
//

import Foundation

final class AudioFilesBrowserViewControllerFactory {
    
    private var browseFilesUseCase: BrowseAudioFilesUseCase
    private var importFileUseCase: ImportAudioFileUseCase
    private var coordinator: AudioFilesBrowserCoordinator
    
    init(
        browseFilesUseCase: BrowseAudioFilesUseCase,
        importFileUseCase: ImportAudioFileUseCase,
        coordinator: AudioFilesBrowserCoordinator
    ) {
        
        self.browseFilesUseCase = browseFilesUseCase
        self.importFileUseCase = importFileUseCase
        self.coordinator = coordinator
    }
    
    func build() -> AudioFilesBrowserViewController {
        
        let viewModel = DefaultAudioFilesBrowserViewModel(
            coordinator: coordinator,
            browseUseCase: browseFilesUseCase,
            importFileUseCase: importFileUseCase
        )
        return AudioFilesBrowserViewController(viewModel: viewModel)
    }
}
