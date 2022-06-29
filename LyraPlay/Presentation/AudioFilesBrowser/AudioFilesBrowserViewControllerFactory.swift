//
//  AudioFilesBrowserViewControllerFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 27.06.22.
//

import Foundation

final class AudioFilesBrowserViewControllerFactory {
    
    private let browseFilesUseCase: BrowseAudioFilesUseCase
    private let importFileUseCase: ImportAudioFileUseCase
    private let coordinator: AudioFilesBrowserCoordinator
    private let audioPlayerUseCase: AudioPlayerUseCase
    
    init(
        coordinator: AudioFilesBrowserCoordinator,
        browseFilesUseCase: BrowseAudioFilesUseCase,
        importFileUseCase: ImportAudioFileUseCase,
        audioPlayerUseCase: AudioPlayerUseCase
    ) {
        
        self.browseFilesUseCase = browseFilesUseCase
        self.importFileUseCase = importFileUseCase
        self.coordinator = coordinator
        self.audioPlayerUseCase = audioPlayerUseCase
    }
    
    func build() -> AudioFilesBrowserViewController {
        
        let viewModel = DefaultAudioFilesBrowserViewModel(
            coordinator: coordinator,
            browseUseCase: browseFilesUseCase,
            importFileUseCase: importFileUseCase,
            audioPlayerUseCase: audioPlayerUseCase
        )
        return AudioFilesBrowserViewController(viewModel: viewModel)
    }
}
