//
//  AudioFilesBrowserViewControllerFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 27.06.22.
//

import Foundation

final class AudioFilesBrowserViewControllerFactory {
    
    private var browseFilesUseCase: BrowseAudioFilesUseCase
    private var coordinator: AudioFilesBrowserCoordinator
    
    init(browseFilesUseCase: BrowseAudioFilesUseCase, coordinator: AudioFilesBrowserCoordinator) {
        
        self.browseFilesUseCase = browseFilesUseCase
        self.coordinator = coordinator
    }
    
    func build() -> AudioFilesBrowserViewController {
        
        let viewModel = DefaultAudioFilesBrowserViewModel(
            browseUseCase: browseFilesUseCase,
            coordinator: coordinator
        )
        return AudioFilesBrowserViewController(viewModel: viewModel)
    }
}
