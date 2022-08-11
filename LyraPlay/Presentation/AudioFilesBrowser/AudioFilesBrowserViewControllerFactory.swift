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
    private let playMediaUseCase: PlayMediaUseCase
    
    init(
        coordinator: AudioFilesBrowserCoordinator,
        browseFilesUseCase: BrowseAudioLibraryUseCase,
        importFileUseCase: ImportAudioFileUseCase,
        playMediaUseCase: PlayMediaUseCase
    ) {
        
        self.browseFilesUseCase = browseFilesUseCase
        self.importFileUseCase = importFileUseCase
        self.coordinator = coordinator
        self.playMediaUseCase = playMediaUseCase
    }
    
    func build() -> AudioFilesBrowserViewController {
        
        let viewModel = DefaultAudioFilesBrowserViewModel(
            coordinator: coordinator,
            browseUseCase: browseFilesUseCase,
            importFileUseCase: importFileUseCase,
            playMediaUseCase: playMediaUseCase
        )
        return AudioFilesBrowserViewController(viewModel: viewModel)
    }
}
