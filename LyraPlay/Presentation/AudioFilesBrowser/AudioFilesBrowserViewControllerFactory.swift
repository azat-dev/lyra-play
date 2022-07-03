//
//  AudioFilesBrowserViewControllerFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 27.06.22.
//

import Foundation

final class AudioFilesBrowserViewControllerFactory {
    
    private let browseFilesUseCase: BrowseAudioLibraryUseCase
    private let importFileUseCase: ImportAudioFileUseCase
    private let coordinator: AudioFilesBrowserCoordinator
    private let playerControlUseCase: PlayerControlUseCase
    
    init(
        coordinator: AudioFilesBrowserCoordinator,
        browseFilesUseCase: BrowseAudioLibraryUseCase,
        importFileUseCase: ImportAudioFileUseCase,
        playerControlUseCase: PlayerControlUseCase
    ) {
        
        self.browseFilesUseCase = browseFilesUseCase
        self.importFileUseCase = importFileUseCase
        self.coordinator = coordinator
        self.playerControlUseCase = playerControlUseCase
    }
    
    func build() -> AudioFilesBrowserViewController {
        
        let viewModel = DefaultAudioFilesBrowserViewModel(
            coordinator: coordinator,
            browseUseCase: browseFilesUseCase,
            importFileUseCase: importFileUseCase,
            playerControlUseCase: playerControlUseCase
        )
        return AudioFilesBrowserViewController(viewModel: viewModel)
    }
}
